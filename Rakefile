# -*- ruby -*-

require "rubygems"
require "hoe"

Hoe.plugin :bundler
Hoe.plugin :debug
Hoe.plugin :git
Hoe.plugin :gemspec
Hoe.plugin :rubygems

Hoe.spec "paperclip-azure" do
  developer("hireross.com", "help@hireross.com")
  license "MIT" # this should match the license in the README

  extra_deps << ['azure-storage-blob', '~> 1.1.0']
  extra_deps << ['hashie', '~> 3.5']
  extra_deps << ['addressable', '~> 2.5']

  extra_dev_deps << ['paperclip', '>= 4.3.6']
  extra_dev_deps << ['sqlite3', '~> 1.3.8']
  extra_dev_deps << ['rspec', '~> 3.0']
  extra_dev_deps << ['simplecov', '~> 0.14']
  extra_dev_deps << ['activerecord', '>= 4.2.0']
  extra_dev_deps << ['activerecord-import', '~> 0.19']
  extra_dev_deps << ['activemodel', '>= 4.2.0']
  extra_dev_deps << ['activesupport', '>= 4.2.0']
end

# vim: syntax=ruby
