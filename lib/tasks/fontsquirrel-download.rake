
namespace :font do
  desc "Download and extract font-squirrel kit. Give Repos with NAME=TeX-Gyre-Bonum"
  task :kit do
    name = ENV["NAME"]
    if name.blank?
      puts "give name to font with rake font:kit NAME=TeX-Gyre-Bonum"
      exit 1
    end
    require "fontsquirrel-download/download"
    FontSquirrel::Download.new name,
                               tmp_name:  Rails.root.join("tmp/fontsquirrel.zip").to_s,
                               font_file: Rails.root.join("app/assets/stylesheets/_fonts.css.sass"),
                               font_dir:  Rails.root.join("app/assets/fonts")

  end
end
