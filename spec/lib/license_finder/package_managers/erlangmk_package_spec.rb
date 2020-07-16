# frozen_string_literal: true

require 'spec_helper'

# /usr/lib/ruby/2.7.0/open3.rb:101:in

module LicenseFinder
  describe ErlangmkPackage do
    subject do
      described_class.new_from_show_dep(
        'rabbit_common: credentials_obfuscation hex https://hex.pm/packages/credentials_obfuscation 2.0.0 /home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
      )
    end

    its(:name) { should == 'credentials_obfuscation' }
    its(:version) { should == '2.0.0' }
    its(:summary) { should == '' }
    its(:description) { should == '' }
    its(:homepage) { should == 'https://hex.pm/packages/credentials_obfuscation' }
    its(:groups) { should == [] }
    its(:children) { should == [] }
    its(:install_path) { should eq '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation' }
    its(:package_manager) { should eq 'Erlangmk' }

    context 'when public github package https://github.com/rabbitmq/rabbitmq-cli.git' do
      let(:dep) { 'parent: rabbitmq_cli git https://github.com/rabbitmq/rabbitmq-cli.git v3.8.3-rc.1 /erlangmk/project/path/deps/rabbitmq_cli' }

      describe '.dep_name' do
        it { expect(described_class.dep_name(dep)).to eql('rabbitmq_cli') }
      end

      describe '.dep_version' do
        it { expect(described_class.dep_version(dep)).to eql('3.8.3-rc.1') }
      end

      describe '.dep_repo' do
        it { expect(described_class.dep_repo(dep)).to eql('https://github.com/rabbitmq/rabbitmq-cli') }
      end

      describe '.dep_path' do
        it { expect(described_class.dep_path(dep)).to eql('/erlangmk/project/path/deps/rabbitmq_cli') }
      end
    end

    context 'when private github package' do
      let(:dep) { 'parent: zstd git+ssh git@github.com:rabbitmq/zstd-erlang master /erlangmk/project/path/deps/zstd' }

      describe '.dep_name' do
        it { expect(described_class.dep_name(dep)).to eql('zstd') }
      end

      describe '.dep_version' do
        it { expect(described_class.dep_version(dep)).to eql('master') }
      end

      describe '.dep_repo' do
        it { expect(described_class.dep_repo(dep)).to eql('https://github.com/rabbitmq/zstd-erlang') }
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
