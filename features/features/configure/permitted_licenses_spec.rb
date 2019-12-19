# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Permitted licenses' do
  # As a developer
  # I want to permit certain licenses that my business has pre-approved
  # So that any dependencies with those licenses do not show up as action items

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  before { developer.create_empty_project }

  specify 'approve dependencies with those licenses' do
    developer.execute_command 'license_finder dependencies add bsd_gem BSD'
    developer.execute_command 'license_finder permitted_licenses add BSD'

    developer.run_license_finder
    expect(developer).to_not be_seeing 'bsd_gem'
  end

  specify 'approve dependencies with any of those licenses' do
    developer.execute_command 'license_finder dependencies add dep_with_many_licenses GPL'
    developer.execute_command 'license_finder licenses add dep_with_many_licenses MIT'
    developer.execute_command 'license_finder permitted_licenses add GPL'

    developer.run_license_finder
    expect(developer).not_to be_seeing 'dep_with_many_licenses'
  end

  specify 'are shown in the CLI' do
    developer.execute_command 'license_finder permitted_licenses add Expat'
    developer.execute_command 'license_finder permitted_licenses list'
    expect(developer).to be_seeing 'MIT'

    developer.execute_command 'license_finder permitted_licenses remove Expat'
    developer.execute_command 'license_finder permitted_licenses list'
    expect(developer).to_not be_seeing 'MIT'
  end
end
