require 'azure'

require File.join(File.dirname(__FILE__), 'paperclip', 'storage', 'azure')

module Azure
  module Blob
    BlobService.class_eval do
      def initialize(signer=Core::Auth::SharedKey.new, account_name=Azure.config.storage_account_name)
        super(signer, account_name)
        @host = Paperclip::Storage::AzureRegion.url_for account_name
      end
    end
  end
end
