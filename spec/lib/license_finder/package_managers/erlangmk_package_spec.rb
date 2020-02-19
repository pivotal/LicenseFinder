# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe ErlangmkPackage do
    subject do
      described_class.new_from_show_dep(
        'DEPI	prometheus	WIP_fetch_method	4.5.0	https://hex.pm/packages/prometheus	/erlangmk/project/path/deps/prometheus'
      )
    end

    its(:name) { should == 'prometheus' }
    its(:version) { should == '4.5.0' }
    its(:summary) { should eq '' }
    its(:description) { should == '' }
    its(:homepage) { should == 'https://hex.pm/packages/prometheus' }
    its(:groups) { should == [] }
    its(:children) { should == [] }
    its(:install_path) { should eq '/erlangmk/project/path/deps/prometheus' }
    its(:package_manager) { should eq 'Erlangmk' }

    context 'when public github package https://github.com/rabbitmq/rabbitmq-cli.git' do
      let(:dep) { 'DEPI	  rabbitmq_cli	WIP_fetch_method	  v3.8.3-rc.1	https://github.com/rabbitmq/rabbitmq-cli.git	/erlangmk/project/path/deps/rabbitmq_cli' }

      describe '.dep_name' do
        it { expect(described_class.dep_name(dep)).to eql('rabbitmq_cli') }
      end

      describe '.dep_version' do
        it { expect(described_class.dep_version(dep)).to eql('3.8.3-rc.1') }
      end

      describe '.dep_url' do
        it { expect(described_class.dep_url(dep)).to eql('https://github.com/rabbitmq/rabbitmq-cli') }
      end

      describe '.dep_path' do
        it { expect(described_class.dep_path(dep)).to eql('/erlangmk/project/path/deps/rabbitmq_cli') }
      end
    end

    context 'when private github package' do
      let(:dep) { 'DEPI	  zstd	WIP_fetch_method	master	git@github.com:rabbitmq/zstd-erlang	/erlangmk/project/path/deps/zstd' }

      describe '.dep_name' do
        it { expect(described_class.dep_name(dep)).to eql('zstd') }
      end

      describe '.dep_version' do
        it { expect(described_class.dep_version(dep)).to eql('master') }
      end

      describe '.dep_url' do
        it { expect(described_class.dep_url(dep)).to eql('https://github.com/rabbitmq/zstd-erlang') }
      end

      describe '.dep_path' do
        it { expect(described_class.dep_path(dep)).to eql('/erlangmk/project/path/deps/zstd') }
      end
    end

    describe 'guards against invalid packages' do
      context 'when empty string' do
        it do
          expect { described_class.new_from_show_dep('') }.to raise_error(InvalidErlangmkPackageError)
        end
      end
    end
  end
end
