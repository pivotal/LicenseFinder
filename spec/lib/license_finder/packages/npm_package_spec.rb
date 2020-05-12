# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe NpmPackage do
    let(:spec) { { name: 'a package', version: '1.1.1' } }
    subject { described_class.new(JSON.parse(spec.to_json)) }

    its(:package_url) { should == 'https://www.npmjs.com/package/a%20package/v/1.1.1' }
  end
end
