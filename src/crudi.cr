require "./crudi/*"
require "db"
require "pg"

module Crudi
  def initdb
    DB.open "postgres://crudi@localhost/crudi" do |db|
      # Make tables and stuff
      db.exec "CREATE SEQUENCE IF NOT EXISTS route_ids"
      db.exec "DROP TABLE IF EXISTS route"
      route_fields = ["id INTEGER",
                      "path TEXT",
                      "port INTEGER"]
      route_field_spec = route_fields.join(",")
      db.exec "CREATE TABLE IF NOT EXISTS route (#{route_field_spec})"

      db.exec "INSERT INTO route (id, path, port) 
VALUES (nextval('route_ids'), '/', 8001)"
    end
  end

end

# main
include Crudi
initdb

# crudi.cr ends here
