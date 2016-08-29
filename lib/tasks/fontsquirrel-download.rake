
namespace :font do
  FONT_FILE = 'app/assets/stylesheets/_fonts.scss'
  desc "Download and extract font-squirrel kit. Give Repos with NAME=TeX-Gyre-Bonum"
  task :download do
    name = ENV["NAME"]
    if name.blank?
      puts "give name to font with rake font:kit NAME=TeX-Gyre-Bonum"
      exit 1
    end
    require "fontsquirrel-download/download"
    runner = FontSquirrel::Download.new name,
      tmp_name:  Rails.root.join("tmp/fontsquirrel.zip").to_s,
      font_file: Rails.root.join(FONT_FILE),
      font_dir:  Rails.root.join("app/assets/fonts")
    runner.download!
    runner.extract_and_apply!
    runner.remove_download_file

  end

  desc "Extract font-squirrel web-fontkit. Takes path to zip-file FILE=/tmp/webfontkit-123.zip"
  task :install do
    name = ENV["FILE"]
    if name.blank?
      puts "provide the path to the font with rake font:install FILE=/tmp/webfontkit-123.zip"
      exit 1
    end
    path = File.expand_path(name)
    require "fontsquirrel-download/download"
    runner = FontSquirrel::Download.new 'webfontkit',
      tmp_name:  path,
      font_file: Rails.root.join(FONT_FILE),
      font_dir:  Rails.root.join("app/assets/fonts")
    runner.extract_and_apply!
  end
end
