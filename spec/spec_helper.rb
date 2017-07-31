require 'simplecov'
require 'rspec'

ROOT = Pathname(File.expand_path(File.join(File.dirname(__FILE__), '..')))

module SimpleCov::Configuration
  def clean_filters
    @filters = []
  end
end

SimpleCov.configure do
  clean_filters
  load_adapter 'test_frameworks'
end

ENV["COVERAGE"] && SimpleCov.start do
  add_filter "/.rvm/"
end

$LOAD_PATH << File.join(ROOT, 'lib')
$LOAD_PATH << File.join(ROOT, 'lib', 'paperclip')
require File.join(ROOT, 'lib', 'paperclip-azure.rb')

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.join(ROOT, 'spec', 'support', '**', '*.rb')].each{|f| require f }

RSpec.configure do |config|
end
