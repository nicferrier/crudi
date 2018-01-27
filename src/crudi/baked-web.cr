require "baked_file_system"
require "http"
require "file"

module BakedWeb

  class NotFound
    def initialize(@path : String)
    end
  end

  # SQL stuff

  class FileStorageSql
    BakedFileSystem.load("/home/nicferrier/crystalwork/crudi/sql")
  end

  def self.get_sql
    all_files = FileStorageSql.files
    all_files.select { |e| e.path.ends_with? ".sql"}
  end

  def self.get_sql_file?(path): BakedFileSystem::BakedFile|NotFound
    begin
      FileStorageSql.get path
    rescue BakedFileSystem::NoSuchFileError
      NotFound.new path
    end
  end


  # WWW stuff

  class FileStorageWWW
    BakedFileSystem.load("/home/nicferrier/crystalwork/crudi/www")
  end

  def self.get_www
    FileStorageWWW.files
  end

  def self.get_www_file?(path) : BakedFileSystem::BakedFile|NotFound
    begin
      FileStorageWWW.get path
    rescue BakedFileSystem::NoSuchFileError
      NotFound.new path
    end
  end

  class BakedHandler
    include HTTP::Handler

    def initialize()
      @fallthrough = false
      @directory_listing = false
    end

    def call(context)
      unless context.request.method == "GET" || context.request.method == "HEAD"
        if @fallthrough
          call_next(context)
        else
          context.response.status_code = 405
          context.response.headers.add("Allow", "GET, HEAD")
        end
        return
      end

      original_path = context.request.path.not_nil!
      is_dir_path = original_path.ends_with? "/"
      request_path = self.request_path(URI.unescape(original_path))

      # File path cannot contains '\0' (NUL) because all filesystem I know
      # don't accept '\0' character as file name.
      if request_path.includes? '\0'
        context.response.status_code = 400
        return
      end

      slashed = request_path.starts_with? "/" 
      asset_path = slashed ? request_path[1,request_path.size - 1] : request_path

      file_asset_path = "www/#{asset_path}"

      if File.exists? file_asset_path
        puts "serving #{asset_path} from the file system"
        send_file file_asset_path, context
      else
        asset = BakedWeb.get_www_file? asset_path
        if asset.is_a? BakedWeb::NotFound
          call_next context
        else
          send asset, context
        end
      end
    end

    def send(asset, context)
      context.response.content_type = mime_type(asset.path)
      data = asset.read.to_slice
      context.response.content_length = data.size
      context.response.write data
    end

    def send_file(file_path, context)
      context.response.content_type = mime_type(file_path)
      data = File.read(file_path).to_slice()
      context.response.content_length = data.size
      context.response.write data
    end
    
    # given a full path of the request, returns the path
    # of the file that should be expanded at the public_dir
    protected def request_path(path : String) : String
      path
    end

    private def redirect_to(context, url)
      context.response.status_code = 302

      url = URI.escape(url) { |b| URI.unreserved?(b) || b != '/' }
      context.response.headers.add "Location", url
    end

    private def mime_type(path)
      case File.extname(path)
      when ".txt"          then "text/plain"
      when ".htm", ".html" then "text/html"
      when ".css"          then "text/css"
      when ".js"           then "application/javascript"
      else                      "application/octet-stream"
      end
    end
    
  end

end
