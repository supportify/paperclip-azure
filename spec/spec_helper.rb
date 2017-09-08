require 'rubygems'
require 'rspec'
require 'active_record'
require 'active_record/version'
require 'active_support'
require 'active_support/core_ext'
require 'ostruct'
require 'pathname'
require 'activerecord-import'
require 'simplecov'
require 'yaml'
require 'paperclip'

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

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])
if ActiveRecord::VERSION::STRING >= "4.2" &&
    ActiveRecord::VERSION::STRING < "5.0"
  ActiveRecord::Base.raise_in_transactional_callbacks = true
end
Paperclip.options[:logger] = ActiveRecord::Base.logger

Dir[File.join(ROOT, 'spec', 'support', '**', '*.rb')].each{|f| require f }

Rails = FakeRails.new('test', Pathname.new(ROOT).join('tmp'))
ActiveSupport::Deprecation.silenced = true

RSpec.configure do |config|
  config.include ModelReconstruction
  config.include TestData
  config.extend VersionHelper
  config.before(:all) do
    rebuild_model
  end
end
