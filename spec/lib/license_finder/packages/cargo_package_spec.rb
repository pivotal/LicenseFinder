# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe CargoPackage do
    let(:crate) { { name: 'a package', version: '1.1.1' } }
    subject { described_class.new(JSON.parse(crate.to_json)) }

    its(:package_url) { should == 'https://crates.io/crates/a+package/1.1.1' }
  end
end
