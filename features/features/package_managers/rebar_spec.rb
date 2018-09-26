# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Rebar Dependencies' do
  # As an Erlang developer
  # I want to be able to manage rebar dependencies

  let(:erlang_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::RebarProject.create
    erlang_developer.run_license_finder
    expect(erlang_developer).to be_seeing_line 'envy, "BRANCH: master", "Apache 2.0"'
  end
end
