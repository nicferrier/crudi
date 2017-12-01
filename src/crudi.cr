require "./crudi/*"
require "db"
require "pg"
require "http/server"
require "json"
require "crikey"

module Crudi
  def self.wiki_page(doc)
    embeddable_doc = doc.gsub("\"", "\\\"")
    [:html, [
       [:head,
        [:link, {
           rel: "stylesheet",
           href: "styles.css",
           type: "text/css"
         }],
        [:script, {src: "wikitext.js"}]],
       [:body,
        [:div, {class: "wikitext"}],
        [:form, {method: "POST",  action: "/page"},
         [:input, {name: "name", placeholder: "wiki name", type: "text"}],
         [:textarea, {name: "wikitext", placeholder: "your page here"}],
         [:input, {type: "submit"}]]],
       [:script, {id: "wiki"},
        "var json_doc = `#{embeddable_doc}`;"]]]
  end

  def self.initroot
    server = HTTP::Server.new(
      "127.0.0.1",
      8001,
      [HTTP::ErrorHandler.new, HTTP::StaticFileHandler.new("./www", true, false)]
    ) do |http|
      wikitext = CrudiDb.get_wiki("Main").to_pretty_json
      doc = self.wiki_page wikitext
      http.response.content_type = "text/html"
      http.response.print Crikey.to_html(doc)
    end
  end
end

# main
CrudiDb.initdb

puts "listening on 8001"
Crudi.initroot.listen

# crudi.cr ends here
