# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'paperclip/azure.rb'

Gem::Specification.new do |gem|
  gem.name          = "paperclip-azure"
  gem.version       = Paperclip::Azure::VERSION
  gem.authors       = ["hireross.com"]
  gem.email         = ["help@hireross.com"]
  gem.summary       = %q{Paperclip-Azure is a Paperclip storage driver for storing files in a Microsoft Azure Blob}
  gem.homepage      = "https://github.com/supportify/paperclip-azure"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = "MIT"


  gem.add_dependency "azure-storage-blob", "~> 2.0"
  gem.add_dependency "hashie", "~> 3.5"
  gem.add_dependency "addressable", "~> 2.5"

  gem.add_development_dependency "paperclip", "~> 4.3", ">= 4.3.6"
  gem.add_development_dependency "sqlite3", "~> 1.3"
  gem.add_development_dependency "rspec", "~> 3.0"
  gem.add_development_dependency "simplecov", "~> 0.14"
  gem.add_development_dependency "activerecord", "~> 4.2", ">= 4.2.0"
  gem.add_development_dependency "activerecord-import", "~> 0.19"
  gem.add_development_dependency "activemodel", "~> 4.2", ">= 4.2.0"
  gem.add_development_dependency "activesupport", "~> 4.2", ">= 4.2.0"
end
