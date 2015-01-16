require 'feature_helper'

describe "Manually Added Dependencies" do
  # As a developer
  # I want to be able to manually add dependencies
  # So that I can track dependencies not managed by Bundler, NPM, etc.

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  before { developer.create_empty_project }

  specify "appear in reports" do
    developer.execute_command 'license_finder dependencies add manual_dep MIT 1.2.3'

    developer.run_license_finder
    expect(developer).to be_seeing 'manual_dep, 1.2.3, MIT'
  end

  specify "can be simultaneously approved" do
    developer.execute_command 'license_finder dependencies add --approve manual Whatever'

    developer.run_license_finder
    expect(developer).not_to be_seeing 'manual_dep'
  end

  specify "appear in the CLI" do
    developer.execute_command 'license_finder dependencies add manual_dep Whatever'
    expect(developer).to be_seeing 'manual_dep'

    developer.execute_command 'license_finder dependencies list'
    expect(developer).to be_seeing 'manual_dep'

    developer.execute_command 'license_finder dependencies remove manual_dep'
    developer.execute_command 'license_finder dependencies list'
    expect(developer).to_not be_seeing 'manual_dep'
  end
end
