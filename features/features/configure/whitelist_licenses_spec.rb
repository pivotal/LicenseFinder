# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Whitelisted licenses' do
  # As a developer
  # I want to whitelist certain licenses that my business has pre-approved
  # So that any dependencies with those licenses do not show up as action items

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  before { developer.create_empty_project }

  specify 'approve dependencies with those licenses' do
    developer.execute_command 'license_finder dependencies add bsd_gem BSD'
    developer.execute_command 'license_finder whitelist add BSD'

    developer.run_license_finder
    expect(developer).to_not be_seeing 'bsd_gem'
  end

  specify 'approve dependencies with any of those licenses' do
    developer.execute_command 'license_finder dependencies add dep_with_many_licenses GPL'
    developer.execute_command 'license_finder licenses add dep_with_many_licenses MIT'
    developer.execute_command 'license_finder whitelist add GPL'

    developer.run_license_finder
    expect(developer).not_to be_seeing 'dep_with_many_licenses'
  end

  specify 'are shown in the CLI' do
    developer.execute_command 'license_finder whitelist add Expat'
    developer.execute_command 'license_finder whitelist list'
    expect(developer).to be_seeing 'MIT'

    developer.execute_command 'license_finder whitelist remove Expat'
    developer.execute_command 'license_finder whitelist list'
    expect(developer).to_not be_seeing 'MIT'
  end
end
