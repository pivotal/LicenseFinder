# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Conda do
    let(:root) { '/fake-conda-project' }
    let(:conda) { Conda.new(project_path: Pathname(root)) }
    it_behaves_like 'a PackageManager'

    let(:environment_yaml) do
      <<INPUT
name: conda_license_test
channels:
- defaults
- conda-forge
- plotly
dependencies:
- numpy
- nodejs>=11.11.0
- openssl
- pip
- python=3.7.3
- pyspark=2.4.5
- zlib
- pip:
  - attrs==19.1.0
  - beautifulsoup4
  - celery==4.3.0
INPUT
    end

    describe '.prepare_command' do
      it 'is a conda env command' do
        expect(conda.prepare_command).to match(/conda env create -f/)
      end
    end

    describe '.prepare' do
      before do
        expect(conda).to receive(:environment_exists?).and_return(exists)
      end
      let(:exists) { false }

      context 'when the environment does not exist' do
        it 'creates the environment' do
          allow(Dir).to receive(:chdir).with(Pathname(root)) { |&block| block.call }
          status = double(Process::Status)
          expect(status).to receive(:success?).and_return true
          expect(conda).to receive(:conda).with(conda.prepare_command).and_return([nil, nil, status])
          conda.prepare
        end
      end

      context 'when the environment does exist' do
        let(:exists) { true }
        it 'does not try to create it' do
          conda.prepare
        end
      end
    end

    describe '.current_packages' do
      let(:status) { double(Process::Status) }

      def stub_conda_list(stdout)
        allow(conda).to receive(:activated_conda).with(/conda list/).and_return([stdout, 'some-error', status])
      end

      def stub_conda_info(info)
        stdout = info.to_json
        allow(conda).to receive(:activated_conda).with(/conda search --info/).and_return([stdout, 'some-error', status])
      end

      def stub_pip_definition(info)
        allow(LicenseFinder::PyPI).to receive(:definition).and_return(info)
      end

      before do
        allow(status).to receive(:success?).and_return(true)
        allow(YAML).to receive(:load_file).and_return(YAML.load(environment_yaml))
      end

      context 'when the package is from the pypi channel' do
        it 'fetches data from PyPi' do
          stub_conda_list <<~LIST_OUTPUT
            # packages in environment at /where/ever:
            #
            # Name                    Version                   Build  Channel
            slackclient               2.8.0                    pypi_0    pypi
          LIST_OUTPUT
          stub_pip_definition('name' => 'slackclient', 'version' => '2.8.0', 'description' => 'slackers rule!')

          expect(conda.current_packages.map { |p| [p.name, p.version, p.description] }).to eq [
            ['slackclient', '2.8.0', 'slackers rule!']
          ]
        end
      end

      context 'when the package is from an unspecified channel' do
        it 'fetches data from conda' do
          stub_conda_list <<~LIST_OUTPUT
            chardet                   3.0.4                 py38_1003
          LIST_OUTPUT

          stub_conda_info(
            'chardet' => [
              {
                'depends' => [
                  'python >=3.5,<3.6.0a0'
                ],
                'license' => 'LGPL2',
                'license_family' => 'GPL',
                'name' => 'chardet',
                'url' => 'https://repo.anaconda.com/pkgs/main/linux-64/chardet-3.0.4-py35hb6e9ddf_1.conda',
                'version' => '3.0.4'
              }
            ]
          )

          expect(conda.current_packages.map { |p| [p.name, p.version, p.children] }).to eq [
            ['chardet', '3.0.4', ['python']]
          ]
        end
      end

      context 'when conda list fails' do
        before do
          allow(status).to receive(:success?).and_return(false)
          allow(conda).to receive(:detected_package_path).and_return('some-file.txt')
          allow(conda).to receive(:activated_conda).and_return(['{"some": "json"}', stderr, status])
        end
        let(:stderr) { 'some error' }

        it 'logs the error and returns an empty list' do
          expect(conda).to receive(:log_errors_with_cmd).with('conda list', stderr).at_least(:once)
          expect(conda.current_packages).to eq([])
        end
      end

      context 'when conda search fails' do
        before do
          allow(conda).to receive(:detected_package_path).and_return('some-file.txt')
          allow(conda).to receive(:environment_name).and_return('nobody_cares')
          allow(conda).to receive(:conda_list).and_return([{ 'name' => 'wackamole', 'version' => '1.0', 'channel' => nil }])

          allow(status).to receive(:success?).and_return(false)
          allow(conda).to receive(:activated_conda).and_return(['{"some": "json error stuff"}', 'some error', status])
        end

        it 'logs the error conda put on stdout and still lists the module' do
          expect(conda).to receive(:log_errors_with_cmd).with(/conda search/, /json error stuff/).at_least(:once)
          current_packages = conda.current_packages
          expect(current_packages.count).to eq 1
          expect(current_packages.first.name).to eq 'wackamole'
        end
      end
    end
  end
end
