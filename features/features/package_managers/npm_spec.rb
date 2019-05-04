# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'NPM Dependencies' do
  # As a Node developer
  # I want to be able to manage NPM dependencies

  let(:node_developer) { LicenseFinder::TestingDSL::User.new }

  specify 'are shown in reports' do
    LicenseFinder::TestingDSL::NpmProject.create
    node_developer.run_license_finder
    expect(node_developer).to be_seeing_line 'http-server, 0.11.1, MIT'
  end
end
