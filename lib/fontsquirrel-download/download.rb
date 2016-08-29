require "open-uri"
require "zip"
module FontSquirrel
  class Download
    TEMPLATE = <<-DOC
@font-face {
  font-family: "{{name}}";
  {{src}}
  font-weight: {{weight}};
  font-style: {{style}};
}
DOC

    # Provide Font-Name as written in URL of font-squirrel,
    # like TeX-Gyre-Bonum
    def initialize(name, options={})
      @options = options
      @name = name
      FileUtils.mkdir_p @options[:font_dir]
      unless File.exists? @options[:font_file]
        FileUtils.touch @options[:font_file]
      end
    end

    def download!
      download(@name)
    end

    def extract_and_apply!
      zipfile = nil
      quietly do
        zipfile = Zip::File.open(@options[:tmp_name])
      end
      zipfile.each do |entry|
        case entry.name
        when %r{/stylesheet.css$}, "stylesheet.css"
          append_stylesheet(entry)
        when /ttf|woff|eot|svg/
          extract_font(entry)
        else
          puts " skipping #{entry.name}"
        end
      end

    ensure
      zipfile.close if zipfile.present?
    end

    def remove_download_file
      FileUtils.rm @options[:tmp_name].to_s
    end

    private

    def name; @name; end

    def append_stylesheet(entry)
      content = entry.get_input_stream.read
      if content.blank?
        puts " error: the stylesheets seems to be empty. Check if the font-kit on fontsquirrel has errors, too, and use the ttf-download + Webfont-generator to make a working zip-file"
        return
      end

      existing = File.read(@options[:font_file].to_s)
      text = Sass::Engine.new(content, syntax: :scss).to_tree.to_scss
      binding.pry
      text.gsub!(/url\(([^\)]+)\)/, "asset-url(\\1, font)")
      parts = text.split("@font-face")
      out_file = ""
      font_name = text.scan(/font-family: '(.*)'/).flatten.inject{|l,s| l=l.chop while l!=s[0...l.length];l}
      parts.each do |part|
        headline =  part.lines.grep(/font-family/).first
        next if !headline
        weight = 'normal'
        style  = 'normal'
        if headline[  /italic/ ]
          style  = 'italic'
        end
        if headline[ /bold/ ]
          weight = 'bold'
        end
        template = TEMPLATE.
          gsub('{{name}}', font_name).
          gsub('{{weight}}', weight).
          gsub('{{style}}', style).
          gsub('{{src}}', part.lines.grep(/src:/).join.strip)
        if !existing.include?(template)
          out_file += template + "\n"
        end
      end
      if out_file.present?
        log "Writing new font-definitions to #{@options[:font_file].to_s} (Font-Family: #{font_name})"
        File.open(@options[:font_file].to_s, "a") {|f| f.write out_file }
      end
    end

    def extract_font(entry)
      target = @options[:font_dir].join(File.basename entry.to_s).to_s
      FileUtils.copy_stream entry.get_input_stream, File.open(target, "wb+")
      log "Extracting #{target}"
    end

    def download(name)
      url = "https://www.fontsquirrel.com/fontfacekit/#{name}"
      log "Downloading #{url}..."
      File.open(@options[:tmp_name], "wb+") { |f| f.write open(url).read }
    end

    def log(msg)
      $stdout.puts msg
    end

  end
end

__END__
