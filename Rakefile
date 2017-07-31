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

  extra_deps << ['azure', '~> 0.7']
  extra_deps << ['hashie', '~> 3.5']
  extra_deps << ['addressable', '~> 2.5']

  extra_dev_deps << ['rspec', '~> 3.0']
  extra_dev_deps << ['simplecov', '~> 0.14']
end

# vim: syntax=ruby
