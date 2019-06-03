# frozen_string_literal: true

require 'spec_helper'
require 'fakefs/spec_helpers'
require 'json'

module LicenseFinder
  describe Composer do
    let(:root) { '/fake-composer-project' }
    let(:composer) { Composer.new project_path: Pathname.new(root) }

    it_behaves_like 'a PackageManager'

    let(:composer_shell_command_output) do
      {
        'require' => {
          'vlucas/phpdotenv' => '3.3.*'
        },
        'require-dev' => {
          'symfony/debug' => '4.2.*'
        }
      }.to_json
    end

    describe '.prepare' do
      subject { Composer.new(project_path: Pathname(root), logger: double(:logger, active: nil)) }

      include FakeFS::SpecHelpers
      before do
        FileUtils.mkdir_p(Dir.tmpdir)
        FileUtils.mkdir_p(root)
      end

      it 'should call composer install' do
        expect(SharedHelpers::Cmd).to receive(:run).with('composer install')
                                                   .and_return([composer_shell_command_output, '', cmd_success])
        subject.prepare
      end
    end

    let(:package_json) do
      {
        'name' => 'license_finder/fixture',
        'description' => 'A sample composer.json file.',
        'version' => '1.0.0',
        'license' => 'MIT',
        'require' => {
          'vlucas/phpdotenv': '3.3.3'
        },
        'require-dev' => {
          'symfony/debug': '4.2.8'
        }
      }.to_json
    end
    let(:license_json) do
      FakeFS.without do
        fixture_from('composer_license.json')
      end
    end

    describe '.current_packages' do
      include FakeFS::SpecHelpers
      before do
        Composer.instance_variable_set(:@modules, nil)
        FileUtils.mkdir_p(root)
        File.write(File.join(root, 'composer.json'), package_json)
        allow(SharedHelpers::Cmd).to receive(:run).with(/composer/).and_return([license_json, '', cmd_success])
      end

      it 'fetches data from composer' do
        current_packages = composer.current_packages

        expect(current_packages.map(&:name)).to eq(['phpoption/phpoption', 'psr/log', 'symfony/debug', 'symfony/polyfill-ctype', 'vlucas/phpdotenv'])
      end

      it 'fails when command fails' do
        allow(SharedHelpers::Cmd).to receive(:run).with(/composer/).and_return(['', 'Some error', cmd_failure])
        expect { composer.current_packages }.to raise_error(RuntimeError)
      end

      it 'does not fail when command fails but produces output' do
        allow(SharedHelpers::Cmd).to receive(:license_json).and_return('foo' => 'bar')
        silence_stderr { composer.current_packages }
      end
    end
  end
end
