require "openssl"

require File.join(File.dirname(__FILE__), "paperclip", "storage", "azure")

module Azure
  module Core
    module Auth
      class SharedAccessSignature
        attr_accessor :version
        attr_accessor :account
        attr_accessor :access_key
        attr_accessor :resource_type

        def initialize(account = ENV["AZURE_STORAGE_ACCOUNT"],
                       access_key = ENV["AZURE_STORAGE_ACCESS_KEY"])
          @version = "2020-02-10"
          @account = account
          @access_key = access_key
          @resource_type = "b"
        end

        def generate_token(container, key, permission = "r", timeout = 900, content_disposition = "")
          expiry = (Time.now.utc + timeout.seconds).utc.iso8601
          resource_path = "/blob/#{@account}/#{container}/#{key[0] == '/' ? key[1..-1] : key}"
          string_to_sign = "#{permission}\n\n#{expiry}\n#{resource_path}\n\n\n\n#{@version}\n" \
            "#{@resource_type}\n\n\n#{content_disposition}\n\n\n"
          "se=#{URI.encode_www_form_component(expiry)}" \
          "&sp=#{permission}" \
          "&sv=#{@version}" \
          "&sr=#{@resource_type}" \
          "&rscd=#{URI.encode_www_form_component(content_disposition)}" \
          "&sig=#{URI.encode_www_form_component(sign_string(@access_key, string_to_sign))}"
        end

        private

        def sign_string(key, string_to_sign)
          digest = OpenSSL::Digest::SHA256.new
          hmac = OpenSSL::HMAC.new(Base64.decode64(key), digest)
          hmac << string_to_sign
          Base64.encode64(hmac.digest).strip
        end
      end
    end
  end
end
