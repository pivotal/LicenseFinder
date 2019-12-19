# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Restricted licenses' do
  # As a lawyer
  # I want to restrict certain licenses
  # So that any dependencies with only these licenses cannot be approved

  let(:developer) { LicenseFinder::TestingDSL::User.new }
  let(:lawyer) { LicenseFinder::TestingDSL::User.new }

  before do
    developer.create_empty_project
    lawyer.execute_command 'license_finder restricted_licenses add BSD'
    developer.execute_command 'license_finder dependencies add restricted_dep BSD'
  end

  specify 'prevent packages from being approved' do
    developer.execute_command 'license_finder approval add restricted_dep'

    lawyer.run_license_finder
    expect(lawyer).to be_seeing 'restricted_dep'
  end

  specify 'override the permitted licenses' do
    developer.execute_command 'license_finder permitted_licenses add BSD'

    lawyer.run_license_finder
    expect(lawyer).to be_seeing 'restricted_dep'
  end
end
