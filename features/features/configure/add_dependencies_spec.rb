require 'feature_helper'

describe "Manually Added Dependencies" do
  # As a developer
  # I want to be able to manually add dependencies
  # So that I can track dependencies not managed by Bundler, NPM, etc.

  let(:user) { LicenseFinder::TestingDSL::User.new }

  before { user.create_empty_project }

  specify "appear in reports" do
    user.execute_command 'license_finder dependencies add manual_dep MIT 1.2.3'

    user.run_license_finder
    expect(user).to be_seeing 'manual_dep, 1.2.3, MIT'
  end

  specify "can be simultaneously approved" do
    user.execute_command 'license_finder dependencies add --approve manual Whatever'

    user.run_license_finder
    expect(user).not_to be_seeing 'manual_dep'
  end

  specify "appear in the CLI" do
    user.execute_command 'license_finder dependencies add manual_dep Whatever'
    expect(user).to be_seeing 'manual_dep'

    user.execute_command 'license_finder dependencies list'
    expect(user).to be_seeing 'manual_dep'

    user.execute_command 'license_finder dependencies remove manual_dep'
    user.execute_command 'license_finder dependencies list'
    expect(user).to_not be_seeing 'manual_dep'
  end
end
