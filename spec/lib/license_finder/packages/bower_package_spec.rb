# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe BowerPackage do
    let(:bower_module) { { pkgMeta: { name: 'a package', version: '1.1.1' } } }
    subject { described_class.new(JSON.parse(bower_module.to_json)) }

    its(:package_url) { should == 'https://bower.io/search/?q=a%20package' }
  end
end
