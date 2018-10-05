# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Go15VendorExperiment do
    include FakeFS::SpecHelpers

    let(:logger) { double(:logger, debug: true, info: true) }
    subject { Go15VendorExperiment.new(options.merge(project_path: Pathname(project_path), logger: logger)) }

    context 'package manager' do
      before do
        FileUtils.mkdir_p File.join(fixture_path('all_pms'), 'vendor')
      end

      it_behaves_like 'a PackageManager'

      it 'installed? should be true if go exists on the path' do
        allow(PackageManager).to receive(:command_exists?).with('go').and_return true
        expect(described_class.installed?).to eq(true)
      end

      it 'installed? should be false if go does not exists on the path' do
        allow(PackageManager).to receive(:command_exists?).with('go').and_return false
        expect(described_class.installed?(logger)).to eq(false)
      end
    end

    let(:project_path) { '/app' }
    let(:options) { {} }

    context 'when there are go files' do
      before do
        FileUtils.mkdir_p project_path
        FileUtils.touch File.join(project_path, 'main.go')
        FileUtils.mkdir_p File.join(project_path, 'vendor', 'github.com', 'foo', 'bar')
        FileUtils.mkdir_p File.join(project_path, 'vendor', 'golang.org', 'bar', 'baz')
      end

      it 'detects the project as go vendor project' do
        expect(subject.active?).to be true
      end

      describe '#current_packages' do
        let(:go_deps) do
          ['github.com/foo/bar', '', cmd_success]
        end
        let(:std_deps) do
          ['stdbar/baz', '', cmd_success]
        end

        before do
          allow(SharedHelpers::Cmd).to receive(:run).with(%q(go list -f "{{join .Deps \"\n\"}}" ./...)).and_return(go_deps)
          allow(SharedHelpers::Cmd).to receive(:run).with('go list std').and_return(std_deps)
          allow(SharedHelpers::Cmd).to receive(:run).with('git rev-list --max-count 1 HEAD').and_return(["e0ff7ae205f\n", '', cmd_success])
        end

        RSpec.shared_examples 'current_packages' do |_parameter|
          it 'only returns the parent package' do
            packages = subject.current_packages
            expect(packages.count).to eq(1)
            expect(packages.first.name).to eq('github.com/foo/bar')
          end
        end

        include_examples 'current_packages'

        it 'uses the sha of the parent project as the dependency version' do
          packages = subject.current_packages
          expect(packages.first.version).to eq('vendored-e0ff7ae205f')
        end

        context 'when sub packages are being used' do
          let(:go_deps) do
            ["github.com/foo/bar\ngithub.com/foo/bar/baz", '', cmd_success]
          end
        end

        context 'when only sub packages are being used' do
          let(:go_deps) do
            ['github.com/foo/bar/baz', '', cmd_success]
          end

          include_examples 'current_packages'
        end

        context 'when unvendored packages are being used' do
          let(:go_deps) do
            ["github.com/foo/bar\ntext/template/parse", '', cmd_success]
          end

          include_examples 'current_packages'
        end

        context 'when standard packages are being used' do
          let(:go_deps) do
            ["github.com/foo/bar\ngolang.org/stdbar/baz", '', cmd_success]
          end

          include_examples 'current_packages'
        end

        context 'when standard package names match part of a nonstandard package' do
          let(:go_deps) do
            ["github.com/foo/bar/my-stdbar/baz\ngolang.org/stdbar/baz", '', cmd_success]
          end

          include_examples 'current_packages'
        end
      end
    end

    context 'when there are go files in subdirectories' do
      before do
        FileUtils.mkdir_p project_path
        FileUtils.mkdir_p File.join(project_path, 'vendor', 'github.com', 'foo', 'bar')
        FileUtils.touch File.join(project_path, 'vendor', 'github.com', 'foo', 'bar', 'main.go')
      end

      it 'detects the project as go vendor project' do
        expect(subject.active?).to be true
      end
    end

    context 'if no go files exist' do
      let(:project_path) { '/ruby_app' }

      before do
        FileUtils.mkdir_p File.join(project_path, 'vendor')
      end

      it 'should not mark the project active' do
        expect(subject.active?).to be false
      end
    end
  end
end
