# -*- encoding: utf-8 -*-
require File.expand_path('../lib/fontsquirrel-download/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Stefan Wienert"]
  gem.email         = ["stefan.wienert@pludoni.de"]
  gem.description   = %q{ Download and extract font-kits from fontsquirrel easily with a rake tasks.}
  gem.summary       = %q{ Download and extract font-kits from fontsquirrel easily with a rake tasks.}
  gem.homepage      = "https://github.com/zealot128/fontsquirrel-download"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "fontsquirrel-download"
  gem.require_paths = ["lib"]
  gem.license       = 'MIT'
  gem.version       = FontSquirrel::VERSION

  gem.add_dependency "rails", ">= 3.1"
  gem.add_dependency "rubyzip", ">= 1.0"
end
