require 'spec_helper'
require 'fakefs/spec_helpers'

module LicenseFinder
  describe Composer do
    let(:root) { "/fake-composer-project" }
    let(:composer) { Composer.new project_path: Pathname.new(root) }

    it_behaves_like "a PackageManager"

    let(:package_json) do
      {
          "name" => "license_finder/fixture",
          "description" => "A sample composer.json file.",
          "version" => "1.0.0",
          "license" => "MIT",
          "require" => {
              "vlucas/phpdotenv" => "2.3.x"
          },
          "require-dev" => {
              "symfony/debug" => "3.0.x"
          }
      }.to_json
    end

    let(:dependency_json) do
      <<-JSON
          {
              "name": "license_finder/fixture",
              "version": "1.0.0",
              "license": [
                  "MIT"
              ],
              "dependencies": {
                  "psr/log": {
                      "version": "1.0.0",
                      "license": [
                          "MIT"
                      ]
                  },
                  "symfony/debug": {
                      "version": "v3.0.7",
                      "license": [
                          "MIT"
                      ]
                  },
                  "vlucas/phpdotenv": {
                      "version": "v2.3.0",
                      "license": [
                          "BSD-3-Clause-Attribution"
                      ]
                  }
              }
          }
      JSON
    end

    describe '.current_packages' do
      include FakeFS::SpecHelpers
      before do
        Composer.instance_variable_set(:@modules, nil)
        FileUtils.mkdir_p(root)
        File.write(File.join(root, "composer.json"), package_json)
        allow(composer).to receive(:capture).with(/composer/).and_return([dependency_json, true])
      end

      it 'fetches data from composer' do
        current_packages = composer.current_packages

        expect(current_packages.map(&:name)).to eq(["psr/log", "symfony/debug", "vlucas/phpdotenv"])
      end

      it "fails when command fails" do
        allow(composer).to receive(:capture).with(/composer/).and_return('Some error', false).once
        expect { composer.current_packages }.to raise_error(RuntimeError)
      end

      it "does not fail when command fails but produces output" do
        allow(composer).to receive(:capture).with(/composer/).and_return('{"foo":"bar"}', false).once
        silence_stderr { composer.current_packages }
      end
    end
  end
end