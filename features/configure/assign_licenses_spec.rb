require 'feature_helper'

describe "Manually Assigned Licenses" do
  # As a developer
  # I want to be able to override the licenses license_finder finds
  # So that my dependencies all have the correct licenses

  let(:user) { LicenseFinder::TestingDSL::User.new }

  specify "are shown in reports" do
    project = user.create_ruby_app
    project.create_gem 'mislicensed_dep', license: 'Unknown'
    project.depend_on_local_gem('mislicensed_dep')
    user.execute_command 'license_finder licenses add mislicensed_dep Known'

    user.run_license_finder
    expect(user).not_to be_seeing_something_like /mislicensed_dep.*Unknown/
    expect(user).to be_seeing_something_like /mislicensed_dep.*Known/
  end
end
