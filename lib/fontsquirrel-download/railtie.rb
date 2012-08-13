module FontSquirrel
  class Railtie < Rails::Railtie
    rake_tasks { load "tasks/fontsquirrel-download.rake" }
    initializer 'fontsquirrel.add_fonts_dir' do |app|
      app.config.assets[:paths] << Rails.root.join("app","assets","fonts").to_s
    end
  end
end
