require 'paperclip/storage/azure/environment'

module Paperclip
  module Storage
    # Azure's container file hosting service is a scalable, easy place to store files for
    # distribution. You can find out more about it at http://azure.microsoft.com/en-us/services/storage/
    #
    # To use Paperclip with Azure, include the +azure-storage-blob+ gem in your Gemfile:
    #   gem 'azure-storage-blob'
    # There are a few Azure-specific options for has_attached_file:
    # * +azure_credentials+: Takes a path, a File, a Hash or a Proc. The path (or File) must point
    #   to a YAML file containing the +storage_access_key+ and +storage_account_name+ that azure
    #   gives you. You can 'environment-space' this just like you do to your
    #   database.yml file, so different environments can use different accounts:
    #     development:
    #       storage_account_name: foo
    #       storage_access_key: 123...
    #     test:
    #       storage_account_name: foo
    #       storage_access_key: abc...
    #     production:
    #       storage_account_name: foo
    #       storage_access_key: 456...
    #   This is not required, however, and the file may simply look like this:
    #     storage_account_name: foo
    #     storage_access_key: 456...
    #   In which case, those access keys will be used in all environments. You can also
    #   put your container name in this file, instead of adding it to the code directly.
    #   This is useful when you want the same account but a different container for
    #   development versus production.
    #   When using a Proc it provides a single parameter which is the attachment itself. A
    #   method #instance is available on the attachment which will take you back to your
    #   code. eg.
    #     class User
    #       has_attached_file :download,
    #                         :storage => :azure,
    #                         :azure_credentials => Proc.new{|a| a.instance.azure_credentials }
    #
    #       def azure_credentials
    #         { :container => "xxx", :storage_account_name => "xxx", :storage_access_key => "xxx" }
    #       end
    #     end
    #
    # * +container+: This is the name of the Azure container that will store your files. Remember
    #   that the container must be unique across the storage account. If the container does not exist
    #   Paperclip will attempt to create it. The container name will not be interpolated.
    #   You can define the container as a Proc if you want to determine it's name at runtime.
    #   Paperclip will call that Proc with attachment as the only argument.
    # * +path+: This is the key under the container in which the file will be stored. The
    #   URL will be constructed from the container and the path. This is what you will want
    #   to interpolate. Keys should be unique, like filenames, and despite the fact that
    #   Azure (strictly speaking) does not support directories, you can still use a / to
    #   separate parts of your file name.
    # * +region+: Depending on the region, different base urls are used. Supported values :global, :de

    module Azure
      def self.extended(base)
        unless defined?(::Azure::Core)
          begin
            require 'azure'
          rescue LoadError => e
            e.message << ' (You may need to install the azure SDK gem)'
            raise e
          end
        end

        base.instance_eval do
          @azure_options = @options[:azure_options] || {}

          unless @options[:url].to_s.match(/\A:azure.*url\z/) || @options[:url] == ':asset_host'
            @options[:path] = path_option.gsub(/:url/, @options[:url]).sub(%r{\A:rails_root/public/system}, '')
            @options[:url]  = ':azure_path_url'
          end
          @options[:url] = @options[:url].inspect if @options[:url].is_a?(Symbol)

          @http_proxy = @options[:http_proxy] || nil
        end

        unless Paperclip::Interpolations.respond_to? :azure_path_url
          Paperclip.interpolates(:azure_path_url) do |attachment, style|
            attachment.azure_uri(style)
          end
        end
        unless Paperclip::Interpolations.respond_to? :asset_host
          Paperclip.interpolates(:asset_host) do |attachment, style|
            attachment.path(style).sub(%r{\A/}, '').to_s
          end
        end
      end

      def expiring_url(time = 3600, style_name = default_style)
        if path(style_name)
          uri = URI azure_uri(style_name)
          generator = ::Azure::Storage::Core::Auth::SharedAccessSignature.new azure_account_name,
                                                                              azure_credentials[:storage_access_key]

          generator.signed_uri uri, false, service: 'b',
                                           resource: 'b',
                                           permissions: 'r',
                                           start: (Time.now - (5 * 60)).utc.iso8601,
                                           expiry: (Time.now + time).utc.iso8601
        else
          url(style_name)
        end
      end

      def auto_connect_duration
        @auto_connect_duration ||= @options[:auto_connect_duration] || azure_credentials[:auto_connect_duration] || 10
        @auto_connect_duration
      end

      def azure_credentials
        @azure_credentials ||= parse_credentials(@options[:azure_credentials])
      end

      def azure_account_name
        account_name = @options[:azure_storage_account_name] || azure_credentials[:storage_account_name]
        account_name = account_name.call(self) if account_name.is_a?(Proc)

        account_name
      end

      def container_name
        @container ||= @options[:container] || azure_credentials[:container]
        @container = @container.call(self) if @container.respond_to?(:call)
        @container || raise(ArgumentError, 'missing required :container option')
      end

      def azure_interface
        @azure_interface ||= begin
          config = {}

          %i[storage_account_name storage_access_key container].each do |opt|
            config[opt] = azure_credentials[opt] if azure_credentials[opt]
          end

          obtain_azure_instance_for(config.merge(@azure_options))
        end
      end

      def azure_storage_client
        config = {}

        %i[storage_account_name storage_access_key].each do |opt|
          config[opt] = azure_credentials[opt] if azure_credentials[opt]
        end

        @azure_storage_client ||= ::Azure::Storage::Client.create config
      end

      def obtain_azure_instance_for(options)
        instances = (Thread.current[:paperclip_azure_instances] ||= {})
        return instances[options] if instance[options]

        if options[:use_development_storage]
          service = ::Azure::Storage::Blob::BlobService.create(use_development_storage: true)
        else
          service = ::Azure::Storage::Blob::BlobService.create(storage_account_name: options[:storage_account_name],
                                                               storage_access_key: options[:storage_access_key])
        end
        instances[options] = service
      end

      def azure_uri(style_name = default_style)
        azure_storage_client.blob_client.generate_uri("#{container_name}/#{path(style_name).gsub(%r{\A/}, '')}")
      end

      def azure_base_url
        Environment.url_for azure_account_name, azure_credentials[:region]
      end

      def azure_container
        @azure_container ||= azure_interface.get_container_properties container_name
      end

      def azure_object(style_name = default_style)
        azure_interface.get_blob_properties container_name, path(style_name).sub(%r{\A/}, '')
      end

      def parse_credentials(creds)
        creds = creds.respond_to?('call') ? creds.call(self) : creds
        creds = find_credentials(creds).stringify_keys
        env = Object.const_defined?(:Rails) ? Rails.env : nil
        (creds[env] || creds).symbolize_keys
      end

      def exists?(style = default_style)
        if original_filename
          !azure_object(style).nil?
        else
          false
        end
      rescue ::Azure::Core::Http::HTTPError => e
        raise unless e.status_code == 404

        false
      end

      def create_container
        azure_interface.create_container container_name
      end

      def flush_writes #:nodoc:
        @queued_for_write.each do |style, file|
          log("saving #{path(style)}")

          write_options = {
            content_type: file.content_type
          }

          if azure_container
            save_blob container_name, path(style).sub(%r{\A/}, ''), file, write_options
          end
        rescue ::Azure::Core::Http::HTTPError => e
          if e.status_code == 404
            create_container
            retry
          else
            raise
          end
        ensure
          file.rewind
        end

        after_flush_writes # allows attachment to clean up temp files

        @queued_for_write = {}
      end

      def save_blob(container_name, storage_path, file, write_options)
        if file.size < 64.megabytes
          azure_interface.create_block_blob container_name, storage_path, file.read, write_options
        else
          blocks = []; count = 0
          while data = file.read(4.megabytes)
            block_id = "block_#{(count += 1).to_s.rjust(5, '0')}"

            azure_interface.put_blob_block container_name, storage_path, block_id, data

            blocks << [block_id]
          end

          azure_interface.commit_blob_blocks container_name, storage_path, blocks
        end
      end

      def flush_deletes #:nodoc:
        @queued_for_delete.each do |path|
          log("deleting #{path}")

          azure_interface.delete_blob container_name, path
        rescue ::Azure::Core::Http::HTTPError => e
          raise unless e.status_code == 404
        end
        @queued_for_delete = []
      end

      def copy_to_local_file(style, local_dest_path)
        log("copying #{path(style)} to local file #{local_dest_path}")

        _, content = azure_interface.get_blob(container_name, path(style).sub(%r{\A/}, ''))

        ::File.open(local_dest_path, 'wb') do |local_file|
          local_file.write(content)
        end
      rescue ::Azure::Core::Http::HTTPError => e
        raise unless e.status_code == 404

        warn("#{e} - cannot copy #{path(style)} to local file #{local_dest_path}")
        false
      end

      private

      def find_credentials(creds)
        case creds
        when File
          YAML.safe_load(ERB.new(File.read(creds.path)).result)
        when String, Pathname
          YAML.safe_load(ERB.new(File.read(creds)).result)
        when Hash
          creds
        when NilClass
          {}
        else
          raise ArgumentError, 'Credentials given are not a path, file, proc, or hash.'
        end
      end
    end
  end
end
