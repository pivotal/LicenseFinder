# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe BowerPackage do
    let(:bower_module) { { pkgMeta: { name: 'a package', version: '1.1.1' } } }
    subject { described_class.new(JSON.parse(bower_module.to_json)) }

    before do
      stub_request(:get, 'https://registry.bower.io/packages/a+package')
        .to_return(status: 200, body: { url: 'https://github.com/owner/package' }.to_json, headers: {})
    end

    its(:package_url) { should == 'https://github.com/owner/package' }
  end
end
