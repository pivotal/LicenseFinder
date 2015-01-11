require 'feature_helper'

describe "Ignored Groups" do
  # As a developer
  # I want to ignore certain groups
  # So that any gems I use in development, or for testing, are automatically approved for use

  let(:user) { LicenseFinder::TestingDSL::User.new }

  specify "are excluded from reports" do
    project = user.create_ruby_app
    gem = user.create_gem 'dev_gem', license: 'GPL'
    project.depend_on gem, groups: ['dev']
    user.execute_command 'license_finder ignored_group add dev'

    user.run_license_finder
    expect(user).to_not be_seeing 'dev_gem'
  end

  specify "appear in the CLI" do
    user.create_empty_project
    user.execute_command 'license_finder ignored_group add dev'
    expect(user).to be_seeing 'dev'
    user.execute_command 'license_finder ignored_group list'
    expect(user).to be_seeing 'dev'

    user.execute_command 'license_finder ignored_group remove dev'
    user.execute_command 'license_finder ignored_group list'
    expect(user).to_not be_seeing 'dev'
  end
end
