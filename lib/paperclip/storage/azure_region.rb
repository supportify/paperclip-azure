module Paperclip
  module Storage
    class AzureRegion

      REGION_URL_POSTFIX = {
        global: "blob.core.windows.net",
        de: "blob.core.cloudapi.de"
      }

      def self.url_for(account_name)
        "http://#{account_name}.#{postfix}"
      end

    private

      def self.postfix
        region = credentials[:region] || :global
        REGION_URL_POSTFIX[region.to_sym]
      end

      def self.credentials
        Paperclip::Attachment.default_options[:azure_credentials]
      end
    end
  end
end
