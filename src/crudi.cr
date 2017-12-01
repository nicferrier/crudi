require "./crudi/*"
require "db"
require "pg"
require "http/server"
require "json"

module Crudi
  def self.initroot
    server = HTTP::Server.new(
      "127.0.0.1",
      8001,
      [HTTP::ErrorHandler.new, HTTP::StaticFileHandler.new("./www", true, false)]
    ) do |http|
      wikitext = CrudiDb.get_wiki("Main").to_pretty_json
      embeddable = wikitext.gsub("\"", "\\\"")
      http.response.content_type = "text/html"
      http.response.print "<!DOCTYPE html>
<html>
<head>
<link rel=\"stylesheet\" type=\"text/css\" href=\"styles.css\"/>
<script src=\"wikitext.js\"></script>
</head>
<body>
<div class=\"wikitext\">
</div>
</body>
<script id=\"wiki\">
var json_doc = `#{embeddable}`;
</script>
</html>"      
    end
  end
end

# main
#CrudiDb.initdb

puts "listening on 8001"
Crudi.initroot.listen

# crudi.cr ends here
