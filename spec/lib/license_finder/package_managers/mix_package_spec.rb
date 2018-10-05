# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe MixPackage do
    subject do
      described_class.new(
        'uuid',
        '1.3.2',
        install_path: 'deps/uuid'
      )
    end

    its(:name) { should == 'uuid' }
    its(:version) { should == '1.3.2' }
    its(:summary) { should eq '' }
    its(:description) { should == '' }
    its(:homepage) { should == '' }
    its(:groups) { should == [] }
    its(:children) { should == [] }
    its(:install_path) { should eq 'deps/uuid' }
    its(:package_manager) { should eq 'Mix' }
  end
end
