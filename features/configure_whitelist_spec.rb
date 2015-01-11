require 'feature_helper'

describe "Whitelisted licenses" do
  # As a developer
  # I want to whitelist certain OSS licenses that my business has pre-approved
  # So that any dependencies with those licenses do not show up as action items

  let(:user) { LicenseFinder::TestingDSL::User.new }

  before { user.create_empty_project }

  specify "approve dependencies with those licenses" do
    user.execute_command 'license_finder dependencies add bsd_gem BSD'
    user.execute_command 'license_finder whitelist add BSD'

    user.run_license_finder
    expect(user).to_not be_seeing 'bsd_gem'
  end

  specify "approve dependencies with any of those licenses" do
    user.execute_command 'license_finder dependencies add dep_with_many_licenses MIT'
    user.execute_command 'license_finder licenses add dep_with_many_licenses GPL'
    user.execute_command 'license_finder whitelist add GPL'

    user.run_license_finder
    expect(user).not_to be_seeing 'dep_with_many_licenses'
  end

  specify "are shown in the CLI" do
    user.execute_command 'license_finder whitelist add Expat'
    expect(user).to be_seeing 'Expat'
    user.execute_command 'license_finder whitelist list'
    expect(user).to be_seeing 'MIT'

    user.execute_command 'license_finder whitelist remove Expat'
    expect(user).to be_seeing 'Expat'
    user.execute_command 'license_finder whitelist list'
    expect(user).to_not be_seeing 'MIT'
  end
end
