require 'feature_helper'

describe "License Finder command line executable" do
  # As a developer
  # I want a command-line interface
  # So that I can manage my application's dependencies and licenses

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  specify "reports unapproved dependencies" do
    developer.create_empty_project
    developer.execute_command("license_finder dependencies add unapproved_gem Whatever")

    developer.run_license_finder
    expect(developer).to be_receiving_exit_code(1)
    expect(developer).to be_seeing 'unapproved_gem'
  end

  specify "reports that all dependencies are approved" do
    developer.create_empty_project

    developer.run_license_finder
    expect(developer).to be_receiving_exit_code(0)
    expect(developer).to be_seeing 'All dependencies are approved for use'
  end

  specify "shows usage and subcommand help" do
    developer.create_empty_project

    developer.execute_command "license_finder help"
    expect(developer).to be_seeing 'license_finder help [COMMAND]'

    developer.execute_command "license_finder ignored_groups help add"
    expect(developer).to be_seeing 'license_finder ignored_groups add GROUP'
  end

  it "reports `license_finder`'s license is MIT" do
    developer.create_ruby_app # has license_finder as a dependency

    developer.run_license_finder
    expect(developer).to be_seeing_something_like /license_finder.*MIT/
  end
end
