require "open-uri"
require "zip/zip"
module FontSquirrel
  class Download
    # Provide Font-Name as written in URL of font-squirrel,
    # like TeX-Gyre-Bonum
    def initialize(name,options={})
      @options=options
      @name = name
      download(name)
      FileUtils.mkdir_p @options[:font_dir]
      Zip::ZipFile.open(@options[:tmp_name]) do |zipfile|
        zipfile.each do |entry|
          case entry.name
          when /stylesheet.css/
            append_stylesheet(entry)
          when /ttf|woff|eot|svg/
            extract_font(entry)
          end
        end
      end
      FileUtils.rm @options[:tmp_name].to_s

    end



    private
    def name; @name; end
    def append_stylesheet(entry)
      content = entry.get_input_stream.read
      text = Sass::Engine.new(content, syntax: :scss).to_tree.to_sass
      text.gsub!(/url\(([^\)]+)\)/, "asset-url(\\1, font)")
      log "Writing new font-definitions to #{@options[:font_file].to_s}"
      File.open(@options[:font_file].to_s, "a") {|f| f.write text }
    end

    def extract_font(entry)
      target = @options[:font_dir].join(entry.name).to_s
      FileUtils.copy_stream entry.get_input_stream, File.open(target, "wb+")
      log "Extracting #{target}"
    end

    def download(name)
      url = "http://www.fontsquirrel.com/fontfacekit/#{name}"
      log "Downloading #{url}..."
      File.open(@options[:tmp_name], "wb+") { |f| f.write open(url).read }
    end

    def log(msg)
      $stdout.puts msg
    end

  end
end
