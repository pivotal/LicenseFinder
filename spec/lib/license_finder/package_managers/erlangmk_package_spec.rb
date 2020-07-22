# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe ErlangmkPackage do
    subject do
      described_class.new(
        'rabbit_common: credentials_obfuscation hex https://hex.pm/packages/credentials_obfuscation 2.0.0' \
        ' /home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
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
      subject do
        described_class.new(
          'parent: rabbitmq_cli git https://github.com/rabbitmq/rabbitmq-cli.git v3.8.3-rc.1 /erlangmk/project/path/deps/rabbitmq_cli'
        )
      end

      its(:name) { should == 'rabbitmq_cli' }
      its(:version) { should == '3.8.3-rc.1' }
      its(:homepage) { should == 'https://github.com/rabbitmq/rabbitmq-cli' }
      its(:install_path) { should eq '/erlangmk/project/path/deps/rabbitmq_cli' }
    end

    context 'when private github package' do
      subject do
        described_class.new(
          'parent: zstd git+ssh git@github.com:rabbitmq/zstd-erlang master /erlangmk/project/path/deps/zstd'
        )
      end

      its(:name) { should == 'zstd' }
      its(:version) { should == 'master' }
      its(:homepage) { should == 'https://github.com/rabbitmq/zstd-erlang' }
      its(:install_path) { should eq '/erlangmk/project/path/deps/zstd' }
    end

    describe 'guards against invalid packages' do
      context 'when empty string' do
        it do
          expect { described_class.new('') }.to raise_error(InvalidErlangmkPackageError)
        end
      end
    end
  end
end
