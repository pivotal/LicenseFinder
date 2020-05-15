# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe YarnPackage do
    subject { described_class.new('a package', '1.1.1') }

    its(:package_url) { should == 'https://yarn.pm/a+package' }
  end
end
