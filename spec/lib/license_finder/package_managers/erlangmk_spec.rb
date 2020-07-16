# frozen_string_literal: true

require 'spec_helper'

module LicenseFinder
  describe Erlangmk do
    subject(:erlangmk) { Erlangmk.new(project_path: '/erlangmk/project') }

    it_behaves_like 'a PackageManager'

    # NOTE:
    # To generate the following output ensure Erlang and Elixir are in your PATH
    # and run the following commands:
    #
    # cd features/fixtures/erlangmk
    # make fetch-deps
    # make query-deps

    query_deps_output = <<-QUERYDEPSOUTPUT
make[1]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit/apps/rabbitmq_prelaunch'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit/apps/rabbitmq_prelaunch'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/amqp_client'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/amqp_client'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_web_dispatch'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_web_dispatch'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management_agent'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management_agent'
make[1]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management'
make[1]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit/apps/rabbitmq_prelaunch'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit/apps/rabbitmq_prelaunch'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/amqp_client'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/amqp_client'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_web_dispatch'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_web_dispatch'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management_agent'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management_agent'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_codegen'
make[3]: *** No rule to make target 'query-deps'.  Stop.
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_codegen'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit/apps/rabbitmq_prelaunch'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[6]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[6]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit/apps/rabbitmq_prelaunch'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[6]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[6]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/amqp_client'
make[2]: *** No rule to make target 'query-deps'.  Stop.
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/amqp_client'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_web_dispatch'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit/apps/rabbitmq_prelaunch'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit/apps/rabbitmq_prelaunch'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowlib'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cowboy'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_web_dispatch'
make[2]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management_agent'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/goldrush'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/lager'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/jsx'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ranch'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/recon'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/credentials_obfuscation'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit_common'
make[3]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit/apps/rabbitmq_prelaunch'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit/apps/rabbitmq_prelaunch'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/observer_cli'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_cli'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/syslog'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/getopt'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/cuttlefish'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/gen_batch_server'
make[5]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[5]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/aten'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/ra'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/sysmon_handler'
make[4]: Entering directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[4]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/stdout_formatter'
make[3]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbit'
make[2]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management_agent'
make[1]: Leaving directory '/home/lbakken/development/rabbitmq/LicenseFinder/features/fixtures/erlangmk/deps/rabbitmq_management'
license_finder_noop_library: rabbitmq_management git https://github.com/rabbitmq/rabbitmq-management v3.8.5
rabbitmq_management: ranch hex https://hex.pm/packages/ranch 1.7.1
rabbitmq_management: rabbit_common git_rmq https://github.com/rabbitmq/rabbitmq-common v3.8.5
rabbitmq_management: rabbit git_rmq https://github.com/rabbitmq/rabbitmq-server v3.8.5
rabbitmq_management: amqp_client git_rmq https://github.com/rabbitmq/rabbitmq-erlang-client v3.8.5
rabbitmq_management: cowboy hex https://hex.pm/packages/cowboy 2.6.1
rabbitmq_management: cowlib hex https://hex.pm/packages/cowlib 2.7.0
rabbitmq_management: rabbitmq_web_dispatch git_rmq https://github.com/rabbitmq/rabbitmq-web-dispatch v3.8.5
rabbitmq_management: rabbitmq_management_agent git_rmq https://github.com/rabbitmq/rabbitmq-management-agent v3.8.5
rabbit_common: rabbitmq_codegen git_rmq https://github.com/rabbitmq/rabbitmq-codegen v3.8.5
rabbit_common: lager hex https://hex.pm/packages/lager 3.8.0
rabbit_common: jsx hex https://hex.pm/packages/jsx 2.9.0
rabbit_common: ranch hex https://hex.pm/packages/ranch 1.7.1
rabbit_common: recon hex https://hex.pm/packages/recon 2.5.1
rabbit_common: credentials_obfuscation hex https://hex.pm/packages/credentials_obfuscation 2.0.0
lager: goldrush git https://github.com/DeadZen/goldrush.git 0.1.9
rabbit: rabbitmq_cli git_rmq https://github.com/rabbitmq/rabbitmq-cli v3.8.5
rabbit: syslog git https://github.com/schlagert/syslog 3.4.5
rabbit: cuttlefish hex https://hex.pm/packages/cuttlefish 2.2.0
rabbit: ranch hex https://hex.pm/packages/ranch 1.7.1
rabbit: lager hex https://hex.pm/packages/lager 3.8.0
rabbit: rabbit_common git_rmq https://github.com/rabbitmq/rabbitmq-common v3.8.5
rabbit: ra hex https://hex.pm/packages/ra 1.1.2
rabbit: sysmon_handler hex https://hex.pm/packages/sysmon_handler 1.2.0
rabbit: stdout_formatter hex https://hex.pm/packages/stdout_formatter 0.2.2
rabbit: recon hex https://hex.pm/packages/recon 2.5.1
rabbit: observer_cli hex https://hex.pm/packages/observer_cli 1.5.4
rabbitmq_cli: rabbit_common git_rmq https://github.com/rabbitmq/rabbitmq-common v3.8.5
rabbitmq_cli: observer_cli hex https://hex.pm/packages/observer_cli 1.5.4
observer_cli: recon hex https://hex.pm/packages/recon 2.5.1
cuttlefish: getopt hex https://hex.pm/packages/getopt 1.0.1
cuttlefish: lager hex https://hex.pm/packages/lager 3.7.0
ra: gen_batch_server hex https://hex.pm/packages/gen_batch_server 0.8.2
ra: aten hex https://hex.pm/packages/aten 0.5.3
cowboy: cowlib git https://github.com/ninenines/cowlib 2.7.0
cowboy: ranch git https://github.com/ninenines/ranch 1.7.1
rabbitmq_web_dispatch: rabbit_common git_rmq https://github.com/rabbitmq/rabbitmq-common v3.8.5
rabbitmq_web_dispatch: rabbit git_rmq https://github.com/rabbitmq/rabbitmq-server v3.8.5
rabbitmq_web_dispatch: cowboy hex https://hex.pm/packages/cowboy 2.6.1
rabbitmq_management_agent: rabbit_common git_rmq https://github.com/rabbitmq/rabbitmq-common v3.8.5
rabbitmq_management_agent: rabbit git_rmq https://github.com/rabbitmq/rabbitmq-server v3.8.5
    QUERYDEPSOUTPUT

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
              .with('make --directory=/erlangmk/project --no-print-directory query-deps')
              .and_return(
                [query_deps_output, '', cmd_success]
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
            41
          )
        end
      end

      context 'when command fails' do
        before do
          expect(SharedHelpers::Cmd).to(
            receive(:run)
              .with('make --directory=/erlangmk/project --no-print-directory query-deps')
              .and_return(
                ['Some error', '', cmd_failure]
              )
          )
        end

        it 'raises command error' do
          expect { erlangmk.current_packages }.to raise_error(
            RuntimeError, %r{Command 'make --directory=\/erlangmk\/project --no-print-directory query-deps' failed to execute}
          )
        end
      end
    end
  end
end
