# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe NugetPackage do
    subject { described_class.new 'nuget_package' }

    its(:package_manager) { should == 'Nuget' }
  end
end
