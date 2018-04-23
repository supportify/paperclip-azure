require 'spec_helper'
require "base64"

describe Paperclip::Storage::Azure do
  let(:storage_access_key) { 'kiaY4+GkLMVxnfOK2X+eCJOE06J8QtHC6XNuXVwt8Pp4kMezYaa7cNjtYnZr4/b732RKdz5pZwl8RN9yb8gBCg==' }

  describe "#parse_credentials" do
    let(:credentials) {{
      'production' => {key: '12345'},
      development: {key: "54321"}
    }}

    before do
      @proxy_settings = {host: "127.0.0.1", port: 8888, user: "foo", password: "bar"}
      rebuild_model storage: :azure,
                    container: "testing",
                    azure_credentials: {not: :important}
      @dummy = Dummy.new
      @avatar = @dummy.avatar
    end

    it "gets the correct credentials when RAILS_ENV is production" do
      rails_env("production") do
        expect(@avatar.parse_credentials(credentials)).to eq({key: "12345"})
      end
    end

    it "gets the correct credentials when RAILS_ENV is development" do
      rails_env("development") do
        expect(@avatar.parse_credentials(credentials)).to eq({key: "54321"})
      end
    end

    it "returns the argument if the key does not exist" do
      rails_env("not really an env") do
        expect(@avatar.parse_credentials(test: "12345")).to eq({test: "12345"})
      end
    end

  end

  describe '#container_name' do
    describe ":container option via :azure_credentials" do
      before do
        rebuild_model storage: :azure,
                      azure_credentials: {container: 'testing'}
        @dummy = Dummy.new
      end

      it "populates #container_name" do
        expect(@dummy.avatar.container_name).to eq('testing')
      end
    end

    describe ":container option" do
      before do
        rebuild_model storage: :azure,
                      container: "testing",
                      azure_credentials: {}
        @dummy = Dummy.new
      end

      it "populates #container_name" do
        expect(@dummy.avatar.container_name).to eq('testing')
      end
    end

    describe "missing :container option" do
      before do
        rebuild_model storage: :azure,
                      azure_credentials: {not: :important}

        @dummy = Dummy.new
        @dummy.avatar = stringy_file
      end

      it "raises an argument error" do
        expect{ @dummy.avatar.container_name }.to raise_error(ArgumentError, /missing required :container option/)
      end
    end
  end

  describe "" do
    before do
      rebuild_model storage: :azure,
                    azure_credentials: {
                      storage_account_name: 'storage',
                      storage_access_key: storage_access_key
                    },
                    container: "container",
                    path: ":attachment/:basename:dotextension",
                    url: ":azure_path_url"

      @dummy = Dummy.new
      @dummy.avatar = stringy_file

      allow(@dummy).to receive(:new_record?).and_return(false)
    end

    it "returns urls based on Azure paths" do
      expect(@dummy.avatar.url).to match(%r{^https://storage.blob.core.windows.net/container/avatars/data[^\.]})
    end
  end

  describe "An attachment that uses Azure for storage and has styles that return different file types" do
    before do
      rebuild_model storage: :azure,
                    styles: { large: ['500x500#', :jpg] },
                    container: "container",
                    path: ":attachment/:basename:dotextension",
                    azure_credentials: {
                      storage_account_name: 'storage',
                      storage_access_key: storage_access_key
                    }

        File.open(fixture_file('5k.png'), 'rb') do |file|
          @dummy = Dummy.new
          @dummy.avatar = file

          allow(@dummy).to receive(:new_record?).and_return(false)
        end
    end

    it "returns a url containing the correct original file mime type" do
      expect(@dummy.avatar.url).to match(/.+\/5k.png/)
    end

    it "returns a url containing the correct processed file mime type" do
      expect(@dummy.avatar.url(:large)).to match(/.+\/5k.jpg/)
    end
  end

  describe "An attachment that uses Azure for storage and has spaces in file name" do
    before do
      rebuild_model storage: :azure,
                    styles: { large: ["500x500#", :jpg] },
                    container: "container",
                    azure_credentials: {
                      storage_account_name: 'storage',
                      storage_access_key: storage_access_key
                    }

      File.open(fixture_file("spaced file.png"), "rb") do |file|
        @dummy = Dummy.new
        @dummy.avatar = file

        allow(@dummy).to receive(:new_record?).and_return(false)
      end
    end

    it "returns a replaced version for path" do
      expect(@dummy.avatar.path).to match(/.+\/spaced_file\.png/)
    end

    it "returns a replaced version for url" do
      expect(@dummy.avatar.url).to match(/.+\/spaced_file\.png/)
    end
  end

  describe "An attachment that uses Azure for storage and has a question mark in file name" do
    before do
      rebuild_model storage: :azure,
                    styles: { large: ['500x500#', :jpg] },
                    container: "container",
                    azure_credentials: {
                      storage_account_name: 'storage',
                      storage_access_key: storage_access_key
                    }

      file = stringy_file
      class << file
        def original_filename
          "question?mark.png"
        end
      end

      @dummy = Dummy.new
      @dummy.avatar = file
      @dummy.save

      allow(@dummy).to receive(:new_record?).and_return(false)
    end

    it "returns a replaced version for path" do
      expect(@dummy.avatar.path).to match(/.+\/question_mark\.png/)
    end

    it "returns a replaced version for url" do
      expect(@dummy.avatar.url).to match(/.+\/question_mark\.png/)
    end
  end

  describe ":asset_host path Interpolations" do
    before do
      rebuild_model storage: :azure,
        azure_credentials: {},
        container: "container",
        path: ":attachment/:basename:dotextension",
        url: ":asset_host"
      @dummy = Dummy.new
      @dummy.avatar = stringy_file
      allow(@dummy).to receive(:new_record?).and_return(false)
    end

    it "returns a relative URL for Rails to calculate assets host" do
      expect(@dummy.avatar.url).to match(%r{^avatars/data[^\.]})
    end
  end

  describe "#expiring_url" do
    before { @dummy = Dummy.new }

    describe "with no attachment" do
      before { expect(@dummy.avatar.exists?).to be_falsey }

      it "returns the default URL" do
        expect(@dummy.avatar.expiring_url).to eq(@dummy.avatar.url)
      end

      it 'generates a url for a style when a file does not exist' do
        expect(@dummy.avatar.expiring_url(3600, :thumb)).to eq(@dummy.avatar.url(:thumb))
      end
    end
  end

  describe "Generating a url with an expiration for each style" do
    before do
      rebuild_model storage: :azure,
                    azure_credentials: {
                      production: {
                        storage_account_name: 'prod_storage',
                        storage_access_key: 'YWNjZXNzLWtleQ==',
                        container: "prod_container"
                      },
                      development: {
                        storage_account_name: 'dev_storage',
                        storage_access_key: 'YWNjZXNzLWtleQ==',
                        container: "dev_container"
                      }
                    },
                    path: ":attachment/:style/:basename:dotextension"

      rails_env("production") do
        @dummy = Dummy.new
        @dummy.avatar = stringy_file
      end

      allow(::Azure::Storage::Core::Auth::SharedAccessSignature).to receive(:new).and_call_original
      allow(::Azure::Storage::Core::Auth::SharedAccessSignatureSigner).to receive(:new).and_call_original
    end

    it "generates a url for the thumb" do
      rails_env("production") do
        expect { @dummy.avatar.expiring_url(1800, :thumb) }.not_to raise_error
      end

      expect(::Azure::Storage::Core::Auth::SharedAccessSignature).to have_received(:new)
        .with('prod_storage', anything)
    end

    it "generates a url for the default style" do
      rails_env("production") do
        expect { @dummy.avatar.expiring_url(1800) }.not_to raise_error
      end

      expect(::Azure::Storage::Core::Auth::SharedAccessSignature).to have_received(:new)
        .with('prod_storage', anything)
    end
  end

  context "Parsing Azure credentials with a container in them" do
    before do
      rebuild_model storage: :azure,
                    azure_credentials: {
                      production: { container: "prod_container" },
                      development: { container: "dev_container" }
                    }
      @dummy = Dummy.new
    end

    it "gets the right container in production" do
      rails_env("production") do
        expect(@dummy.avatar.container_name).to eq("prod_container")
      end
    end

    it "gets the right container in development" do
      rails_env("development") do
        expect(@dummy.avatar.container_name).to eq("dev_container")
      end
    end
  end

  context "An attachment with Azure storage" do
    before do
      rebuild_model storage: :azure,
                    container: "testing",
                    path: ":attachment/:style/:basename:dotextension",
                    azure_credentials: {
                      storage_account_name: 'storage',
                      storage_access_key: storage_access_key
                    }
    end

    it "is extended by the Azure module" do
      expect(Dummy.new.avatar).to be_a(Paperclip::Storage::Azure)
    end

    it "won't be extended by the Filesystem module" do
      expect(Dummy.new.avatar).not_to be_a(Paperclip::Storage::Filesystem)
    end
    end

  describe "An attachment with Azure storage and container defined as a Proc" do
    before do
      rebuild_model storage: :azure,
                    container: lambda { |attachment| "container_#{attachment.instance.other}" },
                    azure_credentials: {not: :important}
    end

    it "gets the right container name" do
      expect(Dummy.new(other: 'a').avatar.container_name).to eq("container_a")
      expect(Dummy.new(other: 'b').avatar.container_name).to eq("container_b")
    end
  end

  context "An attachment with Azure storage and Azure credentials defined as a Proc" do
    before do
      rebuild_model storage: :azure,
                    container: {not: :important},
                    azure_credentials: lambda { |attachment|
                      Hash['storage_access_key' => "secret#{attachment.instance.other}"]
                    }
    end

    it "gets the right credentials" do
      expect(Dummy.new(other: '1234').avatar.azure_credentials[:storage_access_key]).to eq("secret1234")
    end
  end

  context "An attachment with Azure storage and Azure credentials in an unsupported manor" do
    before do
      rebuild_model storage: :azure,
                    container: "testing",
                    azure_credentials: ["unsupported"]
      @dummy = Dummy.new
    end

    it "does not accept the credentials" do
      expect { @dummy.avatar.azure_credentials }.to raise_error(ArgumentError)
    end
  end

  context "An attachment with Azure storage and Azure credentials not supplied" do
    before do
      rebuild_model storage: :azure, container: "testing"
      @dummy = Dummy.new
    end

    it "does not parse any credentials" do
      expect(@dummy.avatar.azure_credentials).to eq({})
    end
  end

  describe "with Azure credentials supplied as Pathname" do
    before do
      ENV['AZURE_CONTAINER'] = 'pathname_container'
      ENV['AZURE_STORAGE_ACCOUNT'] = 'pathname_storage_account'
      ENV['AZURE_STORAGE_ACCESS_KEY'] = storage_access_key

      rails_env('test') do
        rebuild_model storage: :azure,
          azure_credentials: Pathname.new(fixture_file('azure.yml'))

        Dummy.delete_all
        @dummy = Dummy.new
      end
    end

    it "parses the credentials" do
      expect(@dummy.avatar.container_name).to eq('pathname_container')
    end
  end

  describe "with Azure credentials in a YAML file" do
    before do
      ENV['AZURE_CONTAINER'] = 'pathname_container'
      ENV['AZURE_STORAGE_ACCOUNT'] = 'pathname_storage_account'
      ENV['AZURE_STORAGE_ACCESS_KEY'] = storage_access_key

      rails_env('test') do
        rebuild_model storage: :azure,
          azure_credentials: File.new(fixture_file('azure.yml'))

        Dummy.delete_all

        @dummy = Dummy.new
      end
    end

    it "runs the file through ERB" do
      expect(@dummy.avatar.container_name).to eq('pathname_container')
    end
  end

  describe "path is a proc" do
    before do
      rebuild_model storage: :azure,
                    path: ->(attachment) { attachment.instance.attachment_path }

      @dummy = Dummy.new
      @dummy.class_eval do
        def attachment_path
          '/some/dynamic/path'
        end
      end
      @dummy.avatar = stringy_file
    end

    it "returns a correct path" do
      expect(@dummy.avatar.path).to eq('/some/dynamic/path')
    end
  end

  private

  def rails_env(env)
    stored_env, Rails.env = Rails.env, env
    begin
      yield
    ensure
      Rails.env = stored_env
    end
  end
end
