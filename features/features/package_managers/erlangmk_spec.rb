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
    expect(erlang_developer).to be_seeing_line 'rabbit, 3.8.2, "Mozilla Public License 1.1"'
    expect(erlang_developer).to be_seeing_line 'amqp_client, 3.8.2, ""'
    expect(erlang_developer).to be_seeing_line 'cowboy, 2.6.1, "ISC License"'
    expect(erlang_developer).to be_seeing_line 'cowlib, 2.7.0, "ISC License"'
    expect(erlang_developer).to be_seeing_line 'rabbitmq_common, 3.8.2, "Mozilla Public License 1.1"'
    # + MIT, BSD
    expect(erlang_developer).to be_seeing_line 'rabbitmq_management, 3.8.2, "Mozilla Public License 1.1"'
    # + MIT, BSD, ISC, Apache 2.0
    expect(erlang_developer).to be_seeing_line 'rabbitmq_management_agent, 3.8.2, "Mozilla Public License 1.1"'
    expect(erlang_developer).to be_seeing_line 'rabbitmq_web_dispatch, 3.8.2, "Mozilla Public License 1.1"'
    expect(erlang_developer).to be_seeing_line 'ranch, 1.7.1, "ISC License"'
  end
end
