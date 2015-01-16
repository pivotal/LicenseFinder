require 'feature_helper'

describe "Manually Assigned Licenses" do
  # As a developer
  # I want to be able to override the licenses license_finder finds
  # So that my dependencies all have the correct licenses

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  specify "are shown in reports" do
    project = developer.create_ruby_app
    gem = developer.create_gem 'mislicensed_dep', license: 'Unknown'
    project.depend_on gem
    developer.execute_command 'license_finder licenses add mislicensed_dep Known'

    developer.run_license_finder
    expect(developer).not_to be_seeing_something_like /mislicensed_dep.*Unknown/
    expect(developer).to be_seeing_something_like /mislicensed_dep.*Known/
  end
end
