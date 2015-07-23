require_relative '../../support/feature_helper'

describe "License Finder command line executable" do
  # As a developer
  # I want a command-line interface
  # So that I can manage my application's dependencies and licenses

  let(:developer) { LicenseFinder::TestingDSL::User.new }

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

  it "reports dependencies' licenses" do
    developer.create_ruby_app # has license_finder as a dependency, which has thor as a dependency

    developer.run_license_finder
    expect(developer).to be_seeing_something_like /thor.*MIT/
  end

  specify "runs default command" do
    developer.create_empty_project

    developer.run_license_finder
    expect(developer).to be_receiving_exit_code(0)
    expect(developer).to be_seeing 'All dependencies are approved for use'
  end

  specify "displays an error if project_path does not exist" do
    developer.create_empty_project

    developer.execute_command('license_finder report --project-path=/path/that/does/not/exist')
    expect(developer).to be_seeing("Project path '/path/that/does/not/exist' does not exist!")
    expect(developer).to be_receiving_exit_code(1)
  end
end
