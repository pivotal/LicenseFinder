# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Pip do
    let(:root) { '/fake-python-project' }
    let(:pip) { Pip.new(project_path: Pathname(root)) }
    it_behaves_like 'a PackageManager'

    let(:requirements_txt) do
      <<INPUT
tox>=2.3.1,<3.0.0
docutils>=0.10
# botocore and the awscli packages are typically developed
# in tandem, so we're requiring the latest develop
# branch of botocore when working on the awscli.
-e git://github.com/boto/botocore.git@develop#egg=botocore
-e git://github.com/boto/s3transfer.git@develop#egg=s3transfer
-e git://github.com/boto/jmespath.git@develop#egg=jmespath
nose==1.3.0
colorama>=0.2.5,<=0.3.7
mock==1.3.0
rsa>=3.1.2,<=3.5.0
wheel==0.24.0
PyYAML>=3.10,<=3.12"
INPUT
    end

    let(:dependency_json) do
      FakeFS.without do
        fixture_from('pip.json')
      end
    end

    describe '.prepare' do
      include FakeFS::SpecHelpers
      before do
        FileUtils.mkdir_p(Dir.tmpdir)
        FileUtils.mkdir_p(root)
        File.write(File.join(root, 'requirements.txt'), requirements_txt)
        user_provided_dir = File.join(root, 'user-provided')
        @user_provided_requirements = File.join(user_provided_dir, 'requirements.txt')
        FileUtils.mkdir_p(user_provided_dir)
        File.write(@user_provided_requirements, requirements_txt)
      end

      it 'should call pip install with the requirements file' do
        expect(SharedHelpers::Cmd).to receive(:run).with('pip install -r requirements.txt')
                                                   .and_return([dependency_json, '', cmd_success])
        pip.prepare
      end

      context 'user provides a requirements file' do
        let(:pip) { Pip.new(project_path: Pathname(root), pip_requirements_path: @user_provided_requirements) }

        it 'should use the provided requirements file' do
          expect(SharedHelpers::Cmd).to receive(:run).with("pip install -r #{@user_provided_requirements}")
                                                     .and_return([dependency_json, '', cmd_success])
          pip.prepare
        end
      end
    end

    describe '.current_packages' do
      def stub_pip(stdout)
        allow(pip).to receive('`').with(/license_finder_pip.py/).and_return(stdout)
      end

      def stub_pypi(name, version, response)
        stub_request(:get, "https://pypi.org/pypi/#{name}/#{version}/json")
          .to_return(response)
      end

      it 'fetches data from pip' do
        stub_pip [
          { 'name' => 'jasmine', 'version' => '1.3.1', 'location' => 'jasmine/path', 'dependencies' => ['jasmine-core'] },
          { 'name' => 'jasmine-core', 'version' => '1.3.1', 'location' => 'jasmine-core/path' }
        ].to_json
        stub_pypi('jasmine', '1.3.1', status: 200, body: '{}')
        stub_pypi('jasmine-core', '1.3.1', status: 200, body: '{}')

        expect(pip.current_packages.map { |p| [p.name, p.version, p.install_path.to_s, p.children] }).to eq [
          ['jasmine', '1.3.1', 'jasmine/path/jasmine', ['jasmine-core']],
          ['jasmine-core', '1.3.1', 'jasmine-core/path/jasmine-core', []]
        ]
      end

      it 'fetches data from pypi' do
        stub_pip [{ 'name' => 'jasmine', 'version' => '1.3.1', 'location' => 'jasmine/path' }].to_json
        stub_pypi('jasmine', '1.3.1', status: 200, body: JSON.generate(info: { summary: 'A summary' }))

        expect(pip.current_packages.first.summary).to eq 'A summary'
      end

      it 'ignores pypi if it cannot find useful info' do
        stub_pip [{ 'name' => 'jasmine', 'version' => '1.3.1', 'location' => 'jasmine/path' }].to_json
        stub_pypi('jasmine', '1.3.1', status: 404, body: '')

        expect(pip.current_packages.first.summary).to eq ''
      end

      it 'follows pypi redirects' do
        stub_pip [{ 'name' => 'cycler', 'version' => '0.10.0', 'location' => 'cycler/path' }].to_json
        stub_pypi('cycler', '0.10.0', status: 301, headers: { 'location' => 'https://pypi.org/pypi/Cycler/0.10.0/json' })
        stub_pypi('Cycler', '0.10.0', status: 200, body: JSON.generate(info: { summary: 'Cycler summary' }))

        expect(pip.current_packages.first.summary).to eq 'Cycler summary'
      end
    end
  end
end
