require 'feature_helper'

describe "Ignored Dependencies" do
  # As a developer
  # I want to ignore certain dependencies
  # To avoid frequently changing reports about dependencies I know will always be approved

  let(:user) { LicenseFinder::TestingDSL::User.new }

  before do
    user.create_empty_project
    user.execute_command 'license_finder dependencies add ignored_dep Whatever'
  end

  specify "are excluded from reports" do
    user.execute_command 'license_finder ignored_dependencies add ignored_dep'

    user.run_license_finder
    expect(user).to_not be_seeing 'ignored_dep'
    user.execute_command('license_finder report')
    expect(user).to_not be_seeing 'ignored_dep'
  end

  specify "appear in the CLI" do
    user.execute_command 'license_finder ignored_dependencies add ignored_dep'
    expect(user).to be_seeing 'ignored_dep'

    user.execute_command 'license_finder ignored_dependencies list'
    expect(user).to be_seeing 'ignored_dep'

    user.execute_command 'license_finder ignored_dependencies remove ignored_dep'
    user.execute_command 'license_finder ignored_dependencies list'
    expect(user).to_not be_seeing 'ignored_dep'
  end
end
