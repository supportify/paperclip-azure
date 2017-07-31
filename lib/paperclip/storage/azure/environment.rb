module Paperclip
  module Storage
    module Azure
      class Environment

        ENVIRONMENT_SUFFIX = {
          global: 'core.windows.net',
          cn: 'core.chinacloudapi.cn',
          de: "core.cloudapi.de",
          usgovt: 'core.usgovcloudapi.net'
        }

        def self.url_for(account_name, region = :global)
          "#{account_name}.blob.#{ENVIRONMENT_SUFFIX[region]}"
        end
      end
    end
  end
end
