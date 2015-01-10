require 'feature_helper'

describe "Blacklisted licenses" do
  # As a lawyer
  # I want to blacklist certain licenses
  # So that any dependencies with only these licenses cannot be approved

  let(:developer) { LicenseFinder::TestingDSL::User.new }
  let(:lawyer) { LicenseFinder::TestingDSL::User.new }

  before do
    developer.create_empty_project
    lawyer.execute_command 'license_finder blacklist add BSD'
    developer.execute_command 'license_finder dependencies add blacklisted_dep BSD'
  end

  specify "prevent packages from being approved" do
    developer.execute_command 'license_finder approval add blacklisted_dep'

    lawyer.run_license_finder
    expect(lawyer).to be_seeing 'blacklisted_dep'
  end

  specify "override the whitelist" do
    developer.execute_command 'license_finder whitelist add BSD'

    lawyer.run_license_finder
    expect(lawyer).to be_seeing 'blacklisted_dep'
  end
end
