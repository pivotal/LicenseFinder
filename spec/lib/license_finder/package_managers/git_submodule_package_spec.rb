# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe GitSubmodulePackage do
    subject do
      described_class.new(
        'submodules/some-submodule',
        'remotes/origin/feature/who-know-what-would-be-here-g3b54974',
        'path/to/submodules/some-submodule',
        'git@github.com:some-company/this-submodule.git'
      )
    end

    its(:name) { should == 'submodules/some-submodule' }
    its(:version) { should == 'remotes/origin/feature/who-know-what-would-be-here-g3b54974' }
    its(:summary) { should eq '' }
    its(:package_url) { should == 'git@github.com:some-company/this-submodule.git' }
    its(:install_path) { should eq 'path/to/submodules/some-submodule' }
    its(:package_manager) { should eq 'Git Submodule' }
  end
end
