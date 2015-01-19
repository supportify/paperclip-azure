module Azure
  module Blob
    BlobService.class_eval do
      def initialize(signer=Core::Auth::SharedKey.new, account_name=Azure.config.storage_account_name)
        super(signer, account_name)
        @host = "http://#{account_name}.blob.core.windows.net"
      end
    end
  end
end