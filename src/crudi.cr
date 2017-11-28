require "./crudi/*"
require "db"
require "pg"
require "http/server"

module Crudi
  def initdb
    DB.open "postgres://crudi@localhost/crudi" do |db|
      # Make tables and stuff
      db.exec "CREATE SEQUENCE IF NOT EXISTS route_ids"

      ## db.exec "DROP TABLE IF EXISTS route"
      route_fields = ["id INTEGER",
                      "path TEXT",
                      "port INTEGER"]
      route_field_spec = route_fields.join(",")
      db.exec "CREATE TABLE IF NOT EXISTS route (#{route_field_spec})"

      # And some beginning data
      res = db.query "SELECT id FROM route WHERE path = '/'"
      if ! res.move_next
        db.exec "INSERT INTO route (id, path, port)
 VALUES (nextval('route_ids'), ?, ?)", "/", 8001
      end

      # Tables for wiki
      ## db.exec "DROP TABLE IF EXISTS wiki"
      
      db.exec "CREATE SEQUENCE IF NOT EXISTS wiki_ids"
      wiki_fields = ["id INTEGER",
                     "date TIMESTAMP WITH TIME ZONE",
                     "author TEXT",
                     "name TEXT", # the page name?
                     "content JSON"]
      wiki_field_spec = wiki_fields.join(",")
      db.exec "CREATE TABLE IF NOT EXISTS wiki (#{wiki_field_spec})"

      # delete the Main page and recreate
      ## db.exec "DELETE FROM wiki WHERE name='Main'"

      begin
        id = db.query_one "SELECT id FROM wiki WHERE name = 'Main'", &.read(Int)
      rescue ex : DB::Error
        json = %q([{"h1": "Main page"}])
        db.exec "INSERT INTO wiki (id, author, name, content, date) 
VALUES (nextval('wiki_ids'), 'Crudi', 'Main', $1, now())", json
      end


      # Tables for tickets
      ## db.exec "DROP TABLE IF EXISTS ticket"
      
      db.exec "CREATE SEQUENCE IF NOT EXISTS ticket_ids"
      ticket_fields = ["id INTEGER",
                       "date TIMESTAMP WITH TIME ZONE",
                       "title TEXT",
                       "author TEXT",
                       "assigned TEXT",
                       "description JSON", # probably conforming to a doc schema we'll make
                       "comments JSON"]
      ticket_field_spec = ticket_fields.join(",")
      db.exec "CREATE TABLE IF NOT EXISTS ticket (#{ticket_field_spec})"

      # delete the Main page and recreate
      ## db.exec "DELETE FROM wiki WHERE name='Main'"

      begin
        id = db.query_one "SELECT id FROM ticket WHERE title = 'First'", &.read(Int)
      rescue ex : DB::Error
        json = %q([{"h1": ""}])
        db.exec "INSERT INTO ticket (id, date, title, 
author, assigned, 
description, comments) 
VALUES (nextval('ticket_ids'), now(), 'an example ticket',
$1, $1,
'{}', '{}')", "nicferrier"
      end

    end
  end

  def initroot
    server = HTTP::Server.new(8001) do |http_request|
      http_request.response.content_type = "text/html"
      http_request.response.print "<html>Hello</html>"
    end
  end
    

end

# main
include Crudi
initdb
#initroot.listen


# crudi.cr ends here
