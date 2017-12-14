require "db"
require "pg"
require "json"
require "file"
require "io"
require "dir"

# DB routines
module CrudiDb

  class NotFound
    JSON.mapping(name: String)

    def initialize(@name : String)
    end
  end

  class WikiPage
    JSON.mapping(
      name: String,
      id: Int32,
      date: {type: Time, converter: Time::Format.new("%F %T")},
      author: String,
      content: JSON::Any
    )

    def initialize(@name : String,
                   @id : Int32,
                   @date : Time,
                   @author : String,
                   @content : JSON::Any)
    end
  end

  def self.get_wiki?(page) : WikiPage | NotFound
    DB.open "postgres://crudi@localhost/crudi" do |db|
      result = db.query_one? "SELECT id, date, author, content
FROM wiki_page
WHERE name = $1", page, as: {Int32, Time, String, JSON::Any}
      result.try do |res| 
        return WikiPage.new(page, *res)
      end
      # Else we'll just return that we couldn't find it
      return NotFound.new page
    end
  end

  def self.add_wiki(name : String, content : JSON::Any)
    puts "CrudiDb.add_wiki #{name}"
    DB.open "postgres://crudi@localhost/crudi" do |db|
      json_str = content.to_pretty_json
      db.exec(
        "INSERT INTO wiki (id, author, name, content, date)
VALUES (nextval('wiki_ids'), 'Crudi', $1, $2, now())",
        name,
        json_str
      )
    end
  end

  def self.initdb
    DB.open "postgres://crudi@localhost/crudi" do |db|
      sql_dir = Dir.new("sql")
      sql_dir.each do |dirEntry|
        if dirEntry != "." && dirEntry != ".." && !dirEntry.ends_with?("~")
          puts "CrudiDb.initdb executing #{dirEntry}"

          file = File.open("sql/" + dirEntry)
          doc = IO::Memory.new
          IO.copy file, doc
        end;
        
        # Execute it
        db.exec doc.to_s
      end

      db.exec "select schema_init();"
    end
  end
end
