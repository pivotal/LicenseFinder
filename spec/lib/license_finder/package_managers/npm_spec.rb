# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe NPM do
    let(:root) { '/fake-node-project' }
    let(:npm) { NPM.new project_path: Pathname.new(root) }
    let(:cmd_fail_random_status) { double('StatusFailure', exitstatus: 2_234_234, success?: false) }
    let(:cmd_fail_unmet_status) { double('StatusFailure', exitstatus: 1, success?: false) }

    it_behaves_like 'a PackageManager'

    let(:package_json) do
      {
        dependencies: {
          'dependency.js' => '1.3.3.7',
          'dependency2.js' => '4.2'
        },
        devDependencies: {
          'dependency3.js' => '4.2'
        }
      }.to_json
    end

    let(:dependency_json) do
      FakeFS.without do
        fixture_from('npm.json')
      end
    end

    describe '.prepare' do
      include FakeFS::SpecHelpers
      before do
        NPM.instance_variable_set(:@modules, nil)
        FileUtils.mkdir_p(Dir.tmpdir)
        FileUtils.mkdir_p(root)
        File.write(File.join(root, 'package.json'), package_json)
        allow(SharedHelpers::Cmd).to receive(:run).with('npm list --json --long')
                                                  .and_return([dependency_json, '', cmd_success])
      end

      it 'should call npm install' do
        expect(SharedHelpers::Cmd).to receive(:run).with('npm install --no-save')
                                                   .and_return([dependency_json, '', cmd_success])
        npm.prepare
      end

      context 'ignored_groups contains devDependencies' do
        let(:npm) { NPM.new project_path: Pathname.new(root), ignored_groups: 'devDependencies' }
        it 'should include a production flag' do
          expect(SharedHelpers::Cmd).to receive(:run).with('npm install --no-save --production')
                                                     .and_return([dependency_json, '', cmd_success])
          npm.prepare
        end
      end
    end

    describe '.current_packages' do
      include FakeFS::SpecHelpers
      before do
        NPM.instance_variable_set(:@modules, nil)
        FileUtils.mkdir_p(Dir.tmpdir)
        FileUtils.mkdir_p(root)
        File.write(File.join(root, 'package.json'), package_json)
        allow(SharedHelpers::Cmd).to receive(:run).with('npm list --json --long')
                                                  .and_return([dependency_json, '', cmd_success])
      end

      it 'fetches data from npm' do
        current_packages = npm.current_packages
        dependencies = %w[dependency.js dependency1-1.js dependency2.js dependency2-1.js dependency3.js dependency3-1.js]
        expect(current_packages.map(&:name)).to eq(dependencies)
      end

      it 'finds the groups for dependencies' do
        current_packages = npm.current_packages
        expect(current_packages.find { |p| p.name == 'dependency.js' }.groups).to eq(['dependencies'])
        expect(current_packages.find { |p| p.name == 'dependency1-1.js' }.groups).to eq(%w[dependencies devDependencies])
        expect(current_packages.find { |p| p.name == 'dependency2.js' }.groups).to eq(['dependencies'])
        expect(current_packages.find { |p| p.name == 'dependency2-1.js' }.groups).to eq(['dependencies'])
        expect(current_packages.find { |p| p.name == 'dependency3.js' }.groups).to eq(['devDependencies'])
        expect(current_packages.find { |p| p.name == 'dependency3-1.js' }.groups).to eq(['devDependencies'])
      end

      it 'does not support name version string' do
        json = <<-JSON
          {
            "devDependencies": {
              "foo": "4.2"
            }
          }
        JSON

        allow(Dir).to receive(:chdir).with(Pathname('/fake-node-project')) { |&block| block.call }
        allow(npm).to receive(:npm_json).and_return JSON.parse(json)

        current_packages = npm.current_packages
        expect(current_packages.map(&:name)).to eq([])
      end

      it 'fails when command fails' do
        allow(SharedHelpers::Cmd).to receive(:run).with('npm list --json --long').and_return ['', 'error', cmd_fail_random_status]
        expect { npm.current_packages }.to raise_error("Command 'npm list --json --long' failed to execute: error")
      end

      it 'continues when command fails with exitstatus 1' do
        allow(SharedHelpers::Cmd).to receive(:run).with('npm list --json --long').and_return ['{}', 'error', cmd_fail_unmet_status]
        expect { npm.current_packages }.not_to raise_error
      end

      it 'does not fail when command fails but produces output' do
        allow(npm).to receive(:npm_json).and_return('foo' => 'bar')
        silence_stderr { npm.current_packages }
      end

      context 'ignored_groups contains devDependencies' do
        let(:npm) { NPM.new project_path: Pathname.new(root), ignored_groups: 'devDependencies' }
        it 'should include a production flag' do
          expect(SharedHelpers::Cmd).to receive(:run).with('npm list --json --long --production')
                                                     .and_return([dependency_json, '', cmd_success])
          npm.current_packages
        end
      end

      context 'npm recursive dependency edge case - GH#211' do
        let(:package_json) do
          FakeFS.without do
            File.read fixture_path 'npm-recursive-dependencies/package.json'
          end
        end
        let(:dependency_json) do
          FakeFS.without do
            File.read fixture_path 'npm-recursive-dependencies/npm-list.json'
          end
        end

        describe '.current_packages' do
          it 'correctly navigates the dependencies tree and pulls out valid information' do
            expect(npm.current_packages.find { |p| p.name == 'pui-react-alerts' }.version).to eq('3.0.0-alpha.2')
            expect(npm.current_packages.find { |p| p.name == 'pui-react-media' }.version).to eq('3.0.0-alpha.2')
          end
        end
      end

      context 'npm circular license edge case - GH#307' do
        let(:package_json) do
          FakeFS.without do
            File.read fixture_path 'npm-circular-licenses/package.json'
          end
        end
        let(:dependency_json) do
          FakeFS.without do
            File.read fixture_path 'npm-circular-licenses/npm-list.json'
          end
        end

        describe '.current_packages' do
          it 'correctly navigates the dependencies tree and pulls out valid information' do
            FakeFS::FileSystem.clone(File.expand_path('../../../../lib/license_finder/license/templates', __dir__))
            expect(npm.current_packages.find { |p| p.name == 'has' }.licenses.map(&:name)).to eq ['MIT']
            expect(npm.current_packages.find { |p| p.name == 'function-bind' }.licenses.map(&:name)).to eq ['MIT']
          end
        end
      end

      context 'npm licenses is a string - GH#317' do
        let(:package_json) do
          FakeFS.without do
            File.read fixture_path 'npm-licenses-string/package.json'
          end
        end
        let(:dependency_json) do
          FakeFS.without do
            File.read fixture_path 'npm-licenses-string/npm-list.json'
          end
        end

        describe '.current_packages' do
          it 'correctly reports the license type' do
            FakeFS::FileSystem.clone(File.expand_path('../../../../lib/license_finder/license/templates', __dir__))
            expect(npm.current_packages.find { |p| p.name == 'boolbase' }.licenses.map(&:name)).to eq ['ISC']
          end
        end
      end

      context 'when packages have circular dependencies  - GH#313' do
        let(:package_json) do
          FakeFS.without do
            File.read fixture_path 'npm-circular-dependencies/package.json'
          end
        end
        let(:dependency_json) do
          FakeFS.without do
            File.read fixture_path 'npm-circular-dependencies/npm-list.json'
          end
        end

        describe '.current_packages' do
          it 'should return package tree successfully' do
            packages = npm.current_packages
            expect(packages.count).to be > 1
            expect(packages.select { |p| p.name == 'babel-register' }.count).to eq(1)
            expect(packages.select { |p| p.name == 'babel-core' }.count).to eq(1)
            expect(packages.find { |p| p.name == 'babel-register' }.dependencies.count).to be > 0
          end
        end
      end

      context 'when packages have circular dependencies and the stack becomes too deep  - GH#327' do
        let(:package_json) do
          FakeFS.without do
            File.read fixture_path 'npm-stack-too-deep/package.json'
          end
        end
        let(:dependency_json) do
          FakeFS.without do
            File.read fixture_path 'npm-stack-too-deep/npm-list.json'
          end
        end

        describe '.current_packages' do
          it 'should return package tree successfully' do
            packages = npm.current_packages
            expect(packages.count).to be > 1
            expect(packages.select { |p| p.name == 'es6-iterator' }.count).to eq(1)
            expect(packages.select { |p| p.name == 'es5-ext' }.count).to eq(1)
            expect(packages.select { |p| p.name == 'd' }.count).to eq(1)
            expect(packages.find { |p| p.name == 'es6-iterator' }.dependencies.count).to be > 0
            expect(packages.find { |p| p.name == 'es5-ext' }.dependencies.count).to be > 0
            expect(packages.find { |p| p.name == 'd' }.dependencies.count).to be > 0
          end
        end
      end
    end
  end
end
