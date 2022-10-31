# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe PNPMPackage do
    subject { described_class.new('a package', '1.1.1') }

    its(:package_url) { should == 'https://www.npmjs.com/package/a+package/v/1.1.1' }
  end
end
