# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe GitSubmodulePackage do
    subject { described_class.new('some/submodule', '1.1.1', 'installed/path', 'git@github.com:a-company/a-project') }

    its(:name) { should == 'some/submodule'}
    its(:version) { should == '1.1.1' }
    its(:install_path) { should == 'installed/path' }
    its(:package_url) { should == 'git@github.com:a-company/a-project' }
  end
end
