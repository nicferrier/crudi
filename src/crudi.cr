require "./crudi/*"
require "db"
require "pg"
require "http/server"

module Crudi

  def self.initroot
    server = HTTP::Server.new(
      "127.0.0.1",
      8001,
      [HTTP::ErrorHandler.new, HTTP::StaticFileHandler.new("./www", true, false)]
    ) do |http|
      http.response.content_type = "text/html"
      http.response.print "<!DOCTYPE html>
<html>
<head>
<link rel=\"stylesheet\" type=\"text/css\" href=\"styles.css\"/>
</head>
<body>
<h1>Hello</h1>
</body>
</html>"      
    end
  end
end

# main
CrudiDb.initdb

puts "listening on 8001"
Crudi.initroot.listen

# crudi.cr ends here
