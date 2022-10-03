lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "paperclip/azure.rb"

Gem::Specification.new do |gem|
  gem.name          = "paperclip-azure"
  gem.version       = Paperclip::Azure::VERSION
  gem.authors       = ["hireross.com"]
  gem.email         = ["help@hireross.com"]
  gem.summary       = "Paperclip-Azure is a Paperclip storage driver "\
                      "for storing files in a Microsoft Azure Blob"
  gem.homepage      = "https://github.com/supportify/paperclip-azure"

  gem.files         = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.license       = "MIT"

  gem.add_dependency "addressable", "~> 2.5"
  gem.add_dependency "azure-core"
  gem.add_dependency "azure-storage"
  gem.add_dependency "azure-storage-blob"
  gem.add_dependency "hashie", "~> 3.5"

  gem.add_development_dependency "activemodel", ">= 4.2.0"
  gem.add_development_dependency "activerecord", ">= 4.2.0"
  gem.add_development_dependency "activerecord-import", "~> 0.19"
  gem.add_development_dependency "activesupport", ">= 4.2.0"
  gem.add_development_dependency "hoe"
  gem.add_development_dependency "paperclip", ">= 4.3.6"
  gem.add_development_dependency "rspec"
  gem.add_development_dependency "rubocop"
  gem.add_development_dependency "simplecov"
  gem.add_development_dependency "sqlite3", "1.3.13"
end
