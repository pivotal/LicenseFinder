# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Yarn Dependencies' do
  # As a Javascript developer
  # I want to be able to manage Yarn dependencies

  let(:yarn_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::YarnProject.create
    yarn_developer.run_license_finder
    expect(yarn_developer).to be_seeing_line 'http-server, 0.11.1, MIT'
  end
end
