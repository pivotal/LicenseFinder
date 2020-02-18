# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Erlangmk do
    let(:erlangmk_show_deps) do
      <<STDOUT
 GEN    coverdata-clean
 GEN    distclean-tmp
 GEN    distclean-kerl
 GEN    distclean-deps
 GEN    distclean-ct
 GEN    distclean-plt
 GEN    distclean-edoc
 GEN    distclean-escript
 GEN    distclean-relx-rel
 GEN    distclean-xref
 GEN    cover-report-clean
 DEP    rabbitmq_management (v3.8.2)
make[1]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management'
 DEP    rabbit_common (v3.8.2)
 DEP    ranch (1.7.1)
 DEP    rabbit (v3.8.2)
 DEP    amqp_client (v3.8.2)
 DEP    cowboy (2.6.1)
 DEP    cowlib (2.7.0)
 DEP    rabbitmq_web_dispatch (v3.8.2)
 DEP    rabbitmq_management_agent (v3.8.2)
make[2]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[2]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[2]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
 DEP    rabbitmq_codegen (v3.8.2)
 DEP    lager (3.8.0)
/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common
 DEP    jsx (2.9.0)
 DEP    recon (2.5.0)
 DEP    credentials_obfuscation (1.1.0)
make[2]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[2]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
 DEP    rabbitmq_cli (v3.8.2)
 DEP    syslog (3.4.5)
 DEP    ra (1.0.5)
 DEP    sysmon_handler (1.2.0)
 DEP    stdout_formatter (0.2.2)
 DEP    observer_cli (1.5.2)
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[2]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[2]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/amqp_client'
make[2]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/amqp_client'
make[2]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy'
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[2]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy'
make[2]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_web_dispatch'
make[2]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_web_dispatch'
make[2]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management_agent'
make[2]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management_agent'
make[1]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management'
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management v3.8.2 https://github.com/rabbitmq/rabbitmq-management
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch 1.7.1 https://hex.pm/packages/ranch
make[2]: Nothing to be done for 'list-deps-info'.
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common v3.8.2 rabbitmq-common
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit v3.8.2 rabbitmq-server
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/amqp_client v3.8.2 rabbitmq-erlang-client
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy 2.6.1 https://hex.pm/packages/cowboy
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib 2.7.0 https://github.com/ninenines/cowlib
make[3]: Nothing to be done for 'list-deps-info'.
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch 1.7.1 https://github.com/ninenines/ranch
make[3]: Nothing to be done for 'list-deps-info'.
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib 2.7.0 https://hex.pm/packages/cowlib
make[2]: Nothing to be done for 'list-deps-info'.
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_web_dispatch v3.8.2 rabbitmq-web-dispatch
 DEPI   /Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management_agent v3.8.2 rabbitmq-management-agent
STDOUT
    end

    subject(:erlangmk) { Erlangmk.new(project_path: '/erlangmk/project') }

    it_behaves_like 'a PackageManager'

    describe '#package_management_command' do
      it 'is make' do
        expect(
          erlangmk.package_management_command
        ).to eql(
          'make'
        )
      end
    end

    describe '#package_management_command_with_path' do
      it 'is make with directory and no print' do
        expect(
          erlangmk.package_management_command_with_path
        ).to eql(
          'make --directory=/erlangmk/project --no-print-directory'
        )
      end
    end

    describe '#prepare_command' do
      it 'resolves deps' do
        expect(
          erlangmk.prepare_command
        ).to eql(
          'make --directory=/erlangmk/project --no-print-directory fetch-deps'
        )
      end
    end

    describe '#current_packages' do
      context 'when command succeeds' do
        before do
          expect(SharedHelpers::Cmd).to(
            receive(:run)
              .with('make --directory=/erlangmk/project --no-print-directory list-deps-info')
              .and_return(
                [erlangmk_show_deps, '', cmd_success]
              )
          )
        end

        it 'all packages are of type ErlangmkPackages' do
          erlangmk.current_packages.map do |current_package|
            expect(current_package).to be_an(ErlangmkPackage)
          end
        end

        it 'returns the expected number of packages' do
          expect(
            erlangmk.current_packages.size
          ).to eql(
            11
          )
        end
      end

      context 'when command fails' do
        before do
          expect(SharedHelpers::Cmd).to(
            receive(:run)
              .with('make --directory=/erlangmk/project --no-print-directory list-deps-info')
              .and_return(
                ['Some error', '', cmd_failure]
              )
          )
        end

        it 'raises command error' do
          expect { erlangmk.current_packages }.to raise_error(
            RuntimeError, %r{Command 'make --directory=\/erlangmk\/project --no-print-directory list-deps-info' failed to execute}
          )
        end
      end
    end
  end
end
