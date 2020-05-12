# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe CocoaPodsPackage do
    subject { described_class.new("a package", "1.1.1", "") }

    its(:package_url) { should == "https://cocoapods.org/pods/a%20package" }
  end
end
