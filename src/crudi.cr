require "./crudi/crudidb"
require "./crudi/baked-web"
require "db"
require "pg"
require "http/server"
require "tempfile"
require "json"
require "crikey"

module Crudi

  def self.wiki_form
    [:form, {class: "editor", method: "POST",  action: "/page"},
     [:input, {name: "name", placeholder: "wiki name", type: "text"}],
     [:textarea, {name: "wikitext", placeholder: "your page here"}],
     [:input, {type: "submit"}]]
  end

  alias MaybeWikiPage = CrudiDb::WikiPage | CrudiDb::NotFound

  def self.wiki_page(doc : MaybeWikiPage)
    dom_class = "edit"
    dom_class = "not-existing" if doc.is_a? CrudiDb::NotFound

    doc_string = doc.to_json
    json_obj = doc_string.gsub "\"", "\\\""

    [:html, 
     [[:head,
       [:link, {
          rel: "stylesheet",
          href: "styles.css",
          type: "text/css"
        }],
       [:link, {rel: "icon", href: "data:;base64,="}],
       [:script, {src: "wikitext.js", type: "module"}]],
      [:body,
       [:div, {class: "wikitext", contenteditable: false}],
       self.wiki_form],
      [:script, {id: "wiki", class: "#{dom_class}"},
       "var json_doc = `#{json_obj}`;"]]]
  end

  def self.wiki_send(http, page)
    wikitext = CrudiDb.get_wiki? page
    doc = self.wiki_page wikitext
    http.response.content_type = "text/html"
    http.response.status_code = 200
    http.response.print Crikey.to_html(doc)
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
      http.response.status_code = 302
      http.response.headers["location"] = name
    end
  end

  def self.get_wiki(http)
    page = http.request.query_params["page"]
    wikitext = CrudiDb.get_wiki? page
    if wikitext.is_a?(CrudiDb::WikiPage)
      http.response.content_type = "text/html"
      http.response.status_code = 200
      http.response.content_type = "application/json"
      http.response.print wikitext.to_pretty_json
    else
      http.response.respond_with_error "an error getting your wikitext", 500
    end
  end

  def self.upload_attached(http)
    name = nil
    file = nil
    HTTP::FormData.parse(http.request) do |part|
      case part.name
      when "name"
        name = part.body.gets_to_end
        puts "name is #{name}"
      when "file"
        file = Tempfile.open("upload") do |file|
          IO.copy(part.body, file)
        end
        id = self.save_attached file.path
        http.response.status_code = 302
        http.response.headers["location"] = "?name=#{id}"
      end
    end
  end

  def self.save_attached(name : String)
    file = File.open(name) do |file|
      begin
        id = CrudiDb.add_attachment("nicferrier", file)
      rescue ex
        puts "save_attached got an error with db #{ex}"
        ex.inspect_with_backtrace(STDERR)
      end
    end
  end

  def self.get_attached(http) ## totally unsafe
    name = http.request.query_params["name"]
    id = name.to_i
    http.response.content_type = "image/png"
    CrudiDb.get_attachment id, http.response
    http.response.status_code = 200
  end

  def self.initroot
    server = HTTP::Server.new(
      "127.0.0.1",
      8001,
      [HTTP::ErrorHandler.new,
       HTTP::LogHandler.new,
       BakedWeb::BakedHandler.new "www"]
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
      when "/attachment/image"
        case http.request.method
        when "POST"
          self.upload_attached http
        else
          self.get_attached http
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

  def self.getit
    # file = BakedWeb.get_file "wikiedit.js"
    # puts "#{file}"

    # file = BakedWeb.get_file "wikiedit.css"
    # puts "#{file}"

    # file = BakedWeb.get_file "10-schema_init.sql"
    # puts "#{file}"

    BakedWeb.get_www.each do |item|
      puts "www file #{item.path}"
    end
    
    list = BakedWeb.get_sql
    list.each do |item|
      puts "list of files? #{item.path}"
    end
  end

end

# main
#Crudi.getit
CrudiDb.initdb
puts "listening on 8001"
Crudi.initroot.listen

# crudi.cr ends here
