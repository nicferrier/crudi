require "db"
require "pg"
require "json"
require "file"
require "io"

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
FROM wiki 
WHERE name = $1
ORDER BY id DESC
LIMIT 1", page, as: {Int32, Time, String, JSON::Any}
      result.try do |res| 
        return WikiPage.new(page, *res)
      end
      # Else we'll just return that we couldn't find it
      return NotFound.new page
    end
  end

  def self.add_wiki(name : String, content : JSON::Any)
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
    file = File.open("init.sql")
    doc = IO::Memory.new
    IO.copy file, doc
    
    DB.open "postgres://crudi@localhost/crudi" do |db|
      # Create tables and stuff
      db.exec doc.to_s
      db.exec "select schema_init();"
    end
  end
end
