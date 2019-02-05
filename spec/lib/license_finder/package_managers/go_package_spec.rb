# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe GoPackage do
    let(:options) do
      {
        'ImportPath' => 'github.com/pivotal/spec_name',
        'Rev' => '4326c3435332d06b410a2672d28d1343c4059fae'
      }
    end

    let(:full_version) { true }

    subject { described_class.from_dependency(options, Pathname.new('/Go/src'), full_version) }

    its(:name) { should == 'github.com/pivotal/spec_name' }
    its(:version) { should == '4326c3435332d06b410a2672d28d1343c4059fae' }
    its(:install_path) { should == '/Go/src/github.com/pivotal/spec_name' }
    its(:package_manager) { should == 'Go' }

    context 'when full version is set to false' do
      let(:full_version) { false }

      its(:version) { should == '4326c34' }
    end

    context 'when the install path is set in the options' do
      let(:options) { super().merge('InstallPath' => '/Go/vendor/src/github.com/pivotal/spec_name') }

      its(:install_path) { should == '/Go/vendor/src/github.com/pivotal/spec_name' }
    end
  end
end
