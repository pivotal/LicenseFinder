# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe GitSubmodule do
    let(:root) { '/fake-project' }
    let(:gitsubmodule) { GitSubmodule.new project_path: Pathname.new(root) }
    it_behaves_like 'a PackageManager'

    let(:root_dotgitmodules) do 
      FakeFS.without do 
        fixture_from('gitmodule_root')
      end
    end

    let(:sub_dotgitmodules) do 
      FakeFS.without do 
        fixture_from('gitmodule_sub')
      end
    end

    let(:gitsubmodulestatus) do 
      "8d20cb02196cd2147a3eba813ec53d4e89d1007c submodules/dependency_1 (v3.11.0-rc.27-4-g8d20cb02)
b0feea90eddbbdc3e5e2dadf7f7fa00049f1be02 submodules/dependency_2 (remotes/origin/some-branchname)
e2182c392ff1db76bffbb6c05494c90fcd763bb0 submodules/dependency_1/submodules/some-sub-dependency (heads/master)"
    end

    describe '.prepare' do
      include FakeFS::SpecHelpers
      before do
        [ Dir.tmpdir, 
          root
        ].each { |path| FileUtils.mkdir_p(path) }
      end

      it 'should call git submodule upgrade --init --recursive' do
        expect(SharedHelpers::Cmd).to receive(:run).with('git submodule upgrade --init --recursive')
                                                   .and_return([gitsubmodulestatus, '', cmd_success])
        gitsubmodule.prepare
      end
    end

    describe '.current_packages' do
      include FakeFS::SpecHelpers
      before do
        [ Dir.tmpdir, 
          root, 
          File.join(root, "/submodules/dependency_1"), 
          File.join(root, "/submodules/dependency_2")
        ].each { |path| FileUtils.mkdir_p(path) }

        File.write(File.join(root, '.gitmodules'), root_dotgitmodules)
        File.write(File.join(root, 'submodules/dependency_1', '.gitmodules'), sub_dotgitmodules)


        allow(SharedHelpers::Cmd).to receive(:run).with('git submodule status --recursive')
                                                  .and_return([gitsubmodulestatus, '', cmd_success])
      end

      it 'get the package data' do
        current_packages = gitsubmodule.current_packages
        packages = %w[submodules/dependency_1 submodules/dependency_2 submodules/some-sub-dependency]
        versions = %w[v3.11.0-rc.27-4-g8d20cb02 remotes/origin/some-branchname heads/master]

        expect(current_packages.map(&:name).sort).to eq(packages.sort)
        expect(current_packages.map(&:version).sort).to eq(versions.sort)
      end
    end
  end
end
