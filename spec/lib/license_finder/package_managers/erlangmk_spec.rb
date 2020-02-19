# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Erlangmk do
    let(:erlangmk_show_deps) do
      <<STDOUT
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
No beam files found.
Recompile: src/rebar
Recompile: src/rebar_abnfc_compiler
Recompile: src/rebar_app_utils
Recompile: src/rebar_appups
Recompile: src/rebar_asn1_compiler
Recompile: src/rebar_base_compiler
Recompile: src/rebar_cleaner
Recompile: src/rebar_config
Recompile: src/rebar_core
Recompile: src/rebar_cover_utils
Recompile: src/rebar_ct
src/rebar_ct.erl:291: Warning: crypto:rand_uniform/2 is deprecated and will be removed in a future release; use rand:uniform/1
Recompile: src/rebar_deps
Recompile: src/rebar_dia_compiler
Recompile: src/rebar_dialyzer
Recompile: src/rebar_edoc
Recompile: src/rebar_erlc_compiler
Recompile: src/rebar_erlydtl_compiler
Recompile: src/rebar_escripter
Recompile: src/rebar_eunit
src/rebar_eunit.erl:282: Warning: crypto:rand_uniform/2 is deprecated and will be removed in a future release; use rand:uniform/1
Recompile: src/rebar_file_utils
Recompile: src/rebar_getopt
Recompile: src/rebar_lfe_compiler
Recompile: src/rebar_log
Recompile: src/rebar_metacmds
Recompile: src/rebar_mustache
Recompile: src/rebar_neotoma_compiler
Recompile: src/rebar_otp_app
Recompile: src/rebar_otp_appup
Recompile: src/rebar_port_compiler
Recompile: src/rebar_proto_compiler
Recompile: src/rebar_proto_gpb_compiler
Recompile: src/rebar_protobuffs_compiler
Recompile: src/rebar_qc
Recompile: src/rebar_rand_compat
Recompile: src/rebar_rel_utils
Recompile: src/rebar_reltool
Recompile: src/rebar_require_vsn
Recompile: src/rebar_shell
Recompile: src/rebar_subdirs
Recompile: src/rebar_templater
Recompile: src/rebar_upgrade
Recompile: src/rebar_utils
Recompile: src/rebar_xref
Recompile: src/rmemo
==> rebar (compile)
==> rebar (escriptize)
Congratulations! You now have a self-contained script called "rebar" in
your current working directory. Place this script anywhere in your path
and you can use rebar to build OTP-compliant apps.
/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common
 DEP    jsx (2.9.0)
 DEP    recon (2.5.0)
 DEP    credentials_obfuscation (1.1.0)
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
 DEP    goldrush (0.1.9)
make[4]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[4]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[2]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[2]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
 DEP    rabbitmq_cli (v3.8.2)
 DEP    syslog (3.4.5)
 DEP    ra (1.0.5)
 DEP    sysmon_handler (1.2.0)
 DEP    stdout_formatter (0.2.2)
 DEP    observer_cli (1.5.2)
[{"1.1.0",[{<<"recon">>,{pkg,<<"recon">>,<<"2.5.0">>},0}]},
 [{pkg_hash,[{<<"recon">>,
              <<"2F7FCBEC2C35034BADE2F9717F77059DC54EB4E929A3049CA7BA6775C0BD66CD">>}]}]]
[{<<"recon">>,{pkg,<<"recon">>,<<"2.5.0">>},0}]
<<"2.5.0">>
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[4]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[4]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
 DEP    gen_batch_server (0.8.2)
 DEP    aten (0.5.2)
make[4]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[4]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[3]: Entering directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[3]: Leaving directory '/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
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
 DEPI 	rabbitmq_management 	WIP_fetch_method 	v3.8.2 	https://github.com/rabbitmq/rabbitmq-management 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management
 DEPI 	ranch 	WIP_fetch_method 	1.7.1 	https://hex.pm/packages/ranch 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch
 DEPI 	rabbit_common 	WIP_fetch_method 	v3.8.2 	rabbitmq-common 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common
make[2]: *** No rule to make target 'list-deps-info'.  Stop.
 DEPI 	rabbit 	WIP_fetch_method 	v3.8.2 	rabbitmq-server 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit
make[2]: *** No rule to make target 'list-deps-info'.  Stop.
 DEPI 	amqp_client 	WIP_fetch_method 	v3.8.2 	rabbitmq-erlang-client 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/amqp_client
make[2]: *** No rule to make target 'list-deps-info'.  Stop.
 DEPI 	cowboy 	WIP_fetch_method 	2.6.1 	https://hex.pm/packages/cowboy 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy
 DEPI 	cowlib 	WIP_fetch_method 	2.7.0 	https://github.com/ninenines/cowlib 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib
 DEPI 	ranch 	WIP_fetch_method 	1.7.1 	https://github.com/ninenines/ranch 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch
 DEPI 	cowlib 	WIP_fetch_method 	2.7.0 	https://hex.pm/packages/cowlib 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib
 DEPI 	rabbitmq_web_dispatch 	WIP_fetch_method 	v3.8.2 	rabbitmq-web-dispatch 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_web_dispatch
make[2]: *** No rule to make target 'list-deps-info'.  Stop.
 DEPI 	rabbitmq_management_agent 	WIP_fetch_method 	v3.8.2 	rabbitmq-management-agent 	/Users/gerhard/github.com/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management_agent
make[2]: *** No rule to make target 'list-deps-info'.  Stop.
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
