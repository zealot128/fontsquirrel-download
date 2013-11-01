require "open-uri"
require "zip/zip"
module FontSquirrel
  class Download
    TEMPLATE = <<-DOC
@font-face
  font-family: "{{name}}"
{{src}}
  font-weight: {{weight}}
  font-style: {{style}}
DOC

    # Provide Font-Name as written in URL of font-squirrel,
    # like TeX-Gyre-Bonum
    def initialize(name,options={})
      @options=options
      @name = name
      download(name)
      FileUtils.mkdir_p @options[:font_dir]
      zipfile = nil
      quietly do
        zipfile = Zip::ZipFile.open(@options[:tmp_name])
      end
      zipfile.each do |entry|
        case entry.name
        when %r{/stylesheet.css$}
          append_stylesheet(entry)
        when /ttf|woff|eot|svg/
          extract_font(entry)
        end
      end

      FileUtils.rm @options[:tmp_name].to_s
    ensure
      zipfile.close
    end

    private

    def name; @name; end

    def append_stylesheet(entry)
      content = entry.get_input_stream.read
      text = Sass::Engine.new(content, syntax: :scss).to_tree.to_sass
      text.gsub!(/url\(([^\)]+)\)/, "asset-url(\\1, font)")
      headline =  text.lines.grep(/font-family/).first
      weight = 'normal'
      style  = 'normal'
      if headline[  /italic/ ]
        style  = 'italic'
      end
      if headline[ /bold/ ]
        weight = 'bold'
      end
      template = TEMPLATE.
        gsub('{{name}}', @name).
        gsub('{{weight}}', weight).
        gsub('{{style}}', style).
        gsub('{{src}}', text.lines.grep(/src:/).join.strip)
      log "Writing new font-definitions to #{@options[:font_file].to_s} ( Font-Family: #{@name}, #{style}, #{weight})"
      File.open(@options[:font_file].to_s, "a") {|f| f.write template }
    end

    def extract_font(entry)
      target = @options[:font_dir].join(File.basename entry.to_s).to_s
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

__END__
