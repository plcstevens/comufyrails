# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'comufyrails/version'

Gem::Specification.new do |gem|
  gem.name          = "comufyrails"
  gem.version       = Comufyrails::VERSION
  gem.authors       = ["plcstevens"]
  gem.email         = ["philip@tauri-tec.com"]
  gem.description   = %q{Allows rails users to easily hook their application with Comufy.}
  gem.summary       = "comufyrails-#{Comufyrails::VERSION}"
  gem.homepage      = "https://github.com/plcstevens/comufyrails"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_dependency('activesupport',   '~> 3.2.11')
  gem.add_dependency('em-synchrony',    '~> 1.0.2')
  gem.add_dependency('em-http-request', '~> 1.0.3')

  gem.add_development_dependency('rake',  '~> 10.0.3')
  gem.add_development_dependency('rspec', '~> 2.12.0')
end
