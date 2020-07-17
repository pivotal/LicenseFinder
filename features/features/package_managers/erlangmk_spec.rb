# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Erlangmk Dependencies' do
  # As an Erlang developer
  # I want to be able to manage dependencies via Erlang.mk

  let(:erlang_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::ErlangMkProject.create
    puts 'Erlang.mk project created'
    erlang_developer.run_license_finder
    expect(erlang_developer).to be_seeing_line 'amqp_client, master, "Mozilla Public License 2.0"'
    expect(erlang_developer).to be_seeing_line 'aten, 0.5.3, "Apache 2.0"'
    expect(erlang_developer).to be_seeing_line 'cowboy, 2.6.1, ISC'
    expect(erlang_developer).to be_seeing_line 'cowlib, 2.7.0, ISC'
    expect(erlang_developer).to be_seeing_line 'credentials_obfuscation, 2.0.0, "Apache 2.0"'
    expect(erlang_developer).to be_seeing_line 'cuttlefish, 2.3.0, unknown'
    expect(erlang_developer).to be_seeing_line 'elvis_mk, master, "Apache 2.0"'
    expect(erlang_developer).to be_seeing_line 'gen_batch_server, 0.8.3, "Apache 2.0"'
    expect(erlang_developer).to be_seeing_line 'getopt, 1.0.1, unknown'
    expect(erlang_developer).to be_seeing_line 'goldrush, 0.1.9, ISC'
    expect(erlang_developer).to be_seeing_line 'jsx, 2.9.0, MIT'
    expect(erlang_developer).to be_seeing_line 'lager, 3.7.0, "Apache 2.0"'
    expect(erlang_developer).to be_seeing_line 'lager, 3.8.0, "Apache 2.0"'
    expect(erlang_developer).to be_seeing_line 'observer_cli, 1.5.4, MIT'
    expect(erlang_developer).to be_seeing_line 'ra, master, "Apache 2.0, Mozilla Public License 2.0"'
    expect(erlang_developer).to be_seeing_line 'rabbit, master, "Mozilla Public License 2.0"'
    expect(erlang_developer).to be_seeing_line 'rabbit_common, master, "MIT, Mozilla Public License 2.0, New BSD"'
    expect(erlang_developer).to be_seeing_line 'rabbitmq_cli, master, "Mozilla Public License 2.0"'
    expect(erlang_developer).to be_seeing_line 'rabbitmq_codegen, master, "Mozilla Public License 2.0"'
    expect(erlang_developer).to be_seeing_line 'rabbitmq_management, master, "Apache 2.0, ISC, MIT, Mozilla Public License 2.0"'
    expect(erlang_developer).to be_seeing_line 'rabbitmq_management_agent, master, "Mozilla Public License 2.0"'
    expect(erlang_developer).to be_seeing_line 'rabbitmq_web_dispatch, master, "Mozilla Public License 2.0"'
    expect(erlang_developer).to be_seeing_line 'ranch, 1.7.1, ISC'
    expect(erlang_developer).to be_seeing_line 'recon, 2.5.1, "New BSD"'
    expect(erlang_developer).to be_seeing_line 'stdout_formatter, 0.2.2, "Apache 2.0"'
    expect(erlang_developer).to be_seeing_line 'syslog, 3.4.5, MIT'
    expect(erlang_developer).to be_seeing_line 'sysmon_handler, 1.2.0, "Apache 2.0"'
  end
end
