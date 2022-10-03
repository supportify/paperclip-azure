module Paperclip
  module Storage
    module Azure
      class Environment
        ENVIRONMENT_SUFFIX = {
          global: "core.windows.net",
          cn: "core.chinacloudapi.cn",
          de: "core.cloudapi.de",
          usgovt: "core.usgovcloudapi.net"
        }.freeze

        def self.url_for(account_name, region = nil)
          "#{account_name}.blob.#{ENVIRONMENT_SUFFIX[region || :global]}"
        end
      end
    end
  end
end
