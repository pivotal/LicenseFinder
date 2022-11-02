# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Rebar Dependencies' do
  # As an Erlang developer
  # I want to be able to manage rebar dependencies

  let(:erlang_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::RebarProject.create
    erlang_developer.run_license_finder
    expect(erlang_developer).to be_seeing_line 'envy, 0.5.0, MIT'
    expect(erlang_developer).to be_seeing_line 'hackney, 1.6.0, "Apache 2.0"'
    expect(erlang_developer).to be_seeing_line 'certifi, 0.4.0, "New BSD"'
    expect(erlang_developer).to be_seeing_line 'idna, 1.2.0, MIT'
    expect(erlang_developer).to be_seeing_line 'metrics, 1.0.1, BSD'
    expect(erlang_developer).to be_seeing_line 'mimerl, 1.0.2, MIT'
    expect(erlang_developer).to be_seeing_line 'ssl_verify_fun, 1.1.0, MIT'
  end
end
