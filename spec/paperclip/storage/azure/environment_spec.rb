require 'spec_helper'
require 'paperclip/storage/azure/environment'

describe 'Paperclip::Storage::Azure::Environment' do
  subject { Paperclip::Storage::Azure::Environment }

  describe '#url_for' do
    let(:account_name) { 'foo' }

    describe 'when the region is not supplied' do
      it { expect(subject.url_for(account_name)).to eq("#{account_name}.blob.core.windows.net")}
    end

    describe 'when the region is China' do
      it { expect(subject.url_for(account_name, :cn)).to eq("#{account_name}.blob.core.chinacloudapi.cn")}
    end

    describe 'when the region is Germany' do
      it { expect(subject.url_for(account_name, :de)).to eq("#{account_name}.blob.core.cloudapi.de")}
    end

    describe 'when the region is the US Govt' do
      it { expect(subject.url_for(account_name, :usgovt)).to eq("#{account_name}.blob.core.usgovcloudapi.net")}
    end
  end
end
