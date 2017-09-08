require 'azure'

require File.join(File.dirname(__FILE__), 'paperclip', 'storage', 'azure')

module Azure::Storage
  module Blob
    BlobService.class_eval do
      original_initialize = instance_method(:initialize)

      define_method(:initialize) do |options, &block|
        original_initialize.bind(self).(options, &block)
        account_name = options[:client].storage_account_name
        @host = "https://#{Paperclip::Storage::Azure::Environment.url_for(account_name)}"
      end
    end
  end
end
