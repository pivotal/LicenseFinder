# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe NugetPackage do
    subject { described_class.new('a package', '1.1.1') }

    its(:package_url) { should == 'https://www.nuget.org/packages/a+package/1.1.1' }
  end
end
