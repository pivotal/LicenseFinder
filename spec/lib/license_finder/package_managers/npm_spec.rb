require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe NPM do
    let(:root) { '/fake-node-project' }
    let(:npm) { NPM.new project_path: Pathname.new(root) }

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
      <<-JSON
          {
            "dependencies": {
              "dependency.js": {
                "name": "dependency.js",
                "version": "1.3.3.7",
                "description": "description",
                "readme": "readme",
                "path": "/path/to/thing",
                "dependencies": {
                  "dependency1-1.js": {
                    "name": "dependency1-1.js"
                  }
                }
              },
              "dependency2.js": {
                "name": "dependency2.js",
                "version": "4.2",
                "description": "description2",
                "readme": "readme2",
                "path": "/path/to/thing2",
                "dependencies": {
                  "dependency2-1.js": {
                    "name": "dependency2-1.js",
                    "dependencies": {
                      "dependency1-1.js": {
                        "name": "dependency1-1.js"
                      }
                    }
                  }
                }
              },
              "dependency3.js": {
                "name": "dependency3.js",
                "version": "4.2",
                "description": "description3",
                "readme": "readme3",
                "path": "/path/to/thing3",
                "dependencies": {
                  "dependency1-1.js": {
                    "name": "dependency1-1.js"
                  },
                 "dependency3-1.js": {
                    "name": "dependency3-1.js"
                  }
                }
              }
            },
            "notADependency": {
              "dependency6.js": {
                "name": "dep6js",
                "version": "4.2",
                "description": "description6",
                "readme": "readme6",
                "path": "/path/to/thing6"
              }
            }
          }
      JSON
    end

    describe '.current_packages' do
      include FakeFS::SpecHelpers
      before do
        NPM.instance_variable_set(:@modules, nil)
        FileUtils.mkdir_p(Dir.tmpdir)
        FileUtils.mkdir_p(root)
        File.write(File.join(root, 'package.json'), package_json)
        allow(npm).to receive(:capture) do |command|
          filename = command.scan(/> (.*)$/).last.first
          File.write(filename, dependency_json)
          ['', true]
        end
      end

      it 'fetches data from npm' do
        current_packages = npm.current_packages

        expect(current_packages.map(&:name)).to eq(['dependency.js', 'dependency1-1.js', 'dependency2.js', 'dependency2-1.js', 'dependency3.js',  'dependency3-1.js'])
      end

      it 'finds the groups for dependencies' do
        current_packages = npm.current_packages
        expect(current_packages.find { |p| p.name == 'dependency.js' }.groups).to eq(['dependencies'])
        expect(current_packages.find { |p| p.name == 'dependency1-1.js' }.groups).to eq(['dependencies', 'devDependencies'])
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
        allow(npm).to receive(:capture) do |command|
          filename = command.scan(/> (.*)$/).last.first
          File.write(filename, json)
          ['', true]
        end

        current_packages = npm.current_packages
        expect(current_packages.map(&:name)).to eq([])
      end

      it 'fails when command fails' do
        allow(npm).to receive(:capture).with(/npm/).and_return('Some error', false).once
        expect { npm.current_packages }.to raise_error(RuntimeError)
      end

      it 'does not fail when command fails but produces output' do
        allow(npm).to receive(:capture) do |command|
          filename = command.scan(/> (.*)$/).last.first
          File.write(filename, '{"foo":"bar"}')
          ['', false]
        end
        silence_stderr { npm.current_packages }
      end

      context 'when there are multiple versions of the same dependency' do
        let(:package_json) do
          {
              dependencies: {
                  'dependency.js' => '1.3.3.7',
                  'dependency2.js' => '4.2'
              }
          }.to_json
        end

        let(:dependency_json) do
          <<-JSON
          {
            "dependencies": {
              "dependency.js": {
                "name": "dependency.js",
                "version": "1.3.3.7",
                "description": "description",
                "readme": "readme",
                "path": "/path/to/thing1",
                "dependencies": {
                  "twinsie_dependency.js": {
                    "name": "twinsie_dependency.js",
                    "version": "thing-1"
                  }
                }
              },
              "dependency2.js": {
                "name": "dependency2.js",
                "version": "4.2",
                "description": "description2",
                "readme": "readme2",
                "path": "/path/to/thing2",
                "dependencies": {
                  "twinsie_dependency.js": {
                    "name": "twinsie_dependency.js",
                    "version": "thing-2"
                  }
                }
              }
            }
          }
          JSON
        end
        it 'reports multiple dependency versions with the same name' do
          current_packages = npm.current_packages
          expect(current_packages.select { |p| p.name == 'twinsie_dependency.js' }.map(&:version)).to match_array(['thing-1','thing-2'])
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
            FakeFS::FileSystem.clone(File.expand_path('../../../../../lib/license_finder/license/templates', __FILE__))
            expect(npm.current_packages.find {|p| p.name == 'has'}.licenses.map(&:name)).to eq ['MIT']
            expect(npm.current_packages.find {|p| p.name == 'function-bind'}.licenses.map(&:name)).to eq ['MIT']
          end
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
    end
  end
end
