require "db"
require "pg"
require "json"
require "file"
require "io"
require "dir"
require "base64"
require "./baked-web"

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
    begin
      DB.open "postgres://crudi@localhost/crudi" do |db|
        json_str = content.to_pretty_json
        db.exec(
          "INSERT INTO wiki (id, author, name, content, date)
VALUES (nextval('wiki_ids'), 'Crudi', $1, $2, now())",
          name,
          json_str
        )
      end
    rescue ex
      puts "error #{ex}"
    end
  end

  def self.get_attachment(id : Int32, output : IO)
    DB.open "postgres://crudi@localhost/crudi" do |db|
      result = db.query_one?(
        "SELECT date, data 
FROM attachment 
WHERE id = $1",
        id, as: {Time, String})
      result.try do |res|
        data = res[1]
        Base64.decode(data, output)
      end
    end
  end

  def self.add_attachment(author : String, data : IO) : Int32
    blob = IO::Memory.new data.size
    IO.copy(data, blob)
    DB.open "postgres://crudi@localhost/crudi" do |db|
      value = db.scalar(
        "INSERT INTO attachment (id, date, author, data)
VALUES (nextval('attachment_ids'), now(), $1, $2)
RETURNING id",
        author,
        Base64.encode blob
      ).as(Int32)
    end
  end

  def self.initdb
    DB.open "postgres://crudi@localhost/crudi" do |db|
      BakedWeb.get_sql.each do |dirEntry|
        if dirEntry.path.ends_with? ".sql"
          puts "CrudiDb.initdb executing #{dirEntry}"
          doc = dirEntry.read

          # Execute it
          db.exec doc.to_s
        end
      end
      db.exec "select schema_init();"
    end
  end
end
