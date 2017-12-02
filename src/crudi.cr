require "./crudi/*"
require "db"
require "pg"
require "http/server"
require "json"
require "crikey"

module Crudi
  def self.wiki_page(doc : CrudiDb::WikiPage)
    embeddable_doc = doc.to_json.gsub("\"", "\\\"")
    [:html, 
     [[:head,
       [:link, {
          rel: "stylesheet",
          href: "styles.css",
          type: "text/css"
        }],
       [:link, {rel: "icon", href: "data:;base64,="}],
       [:script, {src: "wikitext.js"}]],
      [:body,
       [:div, {class: "wikitext"}],
       self.wiki_form],
      [:script,
       {id: "wiki"},
       "var json_doc = `#{embeddable_doc}`;"]]]
  end

  def self.wiki_form
    [:form, {class: "editor", method: "POST",  action: "/page"},
     [:input, {name: "name", placeholder: "wiki name", type: "text"}],
     [:textarea, {name: "wikitext", placeholder: "your page here"}],
     [:input, {type: "submit"}]]
  end

  def self.wiki_send(http, page)
    puts "wiki_send called for #{page}"
    wikitext = CrudiDb.get_wiki(page)
    if wikitext.is_a?(Nil)
      http.response.respond_with_error "an error occurred with your wiki markup", 500
    else
      doc = self.wiki_page wikitext
      http.response.content_type = "text/html"
      http.response.status_code = 200
      http.response.print Crikey.to_html(doc)
    end
  end

  def self.update_wiki(http)
    body = http.request.body
    if body.is_a?(Nil)
      http.response.status_code = 400
    elsif body.is_a?(IO)
      body_data = body.gets_to_end
      form_data = HTTP::Params.parse body_data
      name = form_data["name"]
      wiki_source = form_data["wikitext"]
      doc = JSON.parse wiki_source
      CrudiDb.add_wiki(name, doc)
      http.response.status_code  = 302
      http.response.headers["location"] = name
    end
  end

  def self.get_wiki(http)
    page = http.request.query_params["page"]
    wikitext = CrudiDb.get_wiki(page)
    if wikitext.is_a?(Nil)
      http.response.respond_with_error "an error getting your wikitext", 500
    else
      http.response.content_type = "text/html"
      http.response.status_code = 200
      http.response.content_type = "application/json"
      http.response.print wikitext.to_pretty_json
    end
  end

  def self.initroot
    server = HTTP::Server.new(
      "127.0.0.1",
      8001,
      [HTTP::ErrorHandler.new,
       HTTP::StaticFileHandler.new("./www", true, false)]
    ) do |http|
      case http.request.path
      when "/favicon.ico"
        http.response.respond_with_error "no icon", 404
      when "/page"
        case http.request.method
        when "GET"
          self.get_wiki http
        when "POST"
          self.update_wiki http
        else
          http.response.respond_with_error "not supported", 405
        end
      when "/"
        self.wiki_send http, "Main"
      else
        # if we get a page that's not root we must take the leading slash off
        path = http.request.path[1..-1]
        self.wiki_send http, path
      end
    end
  end

end

# main
CrudiDb.initdb
puts "listening on 8001"
Crudi.initroot.listen

# crudi.cr ends here
