# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Project path' do
  # As a developer
  # I want to set a project path
  # So that I can run license finder in a different Bundle environment to the project.

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  specify 'can be overridden on the command line' do
    project = developer.create_ruby_app
    gem = developer.create_gem 'mitlicensed_dep', license: 'MIT', version: '1.2.3'
    project.depend_on gem
    developer.execute_command_outside_project("license_finder --quiet --project_path #{project.project_dir}")
    expect(developer).to be_seeing 'mitlicensed_dep, 1.2.3, MIT'
  end

  specify 'works with vendored bundle and a project_path' do
    project = LicenseFinder::TestingDSL::VendorBundlerProject.create
    developer.execute_command_outside_project("license_finder --quiet --project_path #{project.project_dir}")
    expect(developer).to be_seeing_line 'rake, 12.3.0, MIT'
  end
end
