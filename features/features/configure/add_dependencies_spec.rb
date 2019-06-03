# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Manually Added Dependencies' do
  # As a developer
  # I want to be able to manually add dependencies
  # So that I can track dependencies not managed by any official package manager

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  before { developer.create_empty_project }

  specify 'appear in reports' do
    developer.execute_command 'license_finder dependencies add manual_dep MIT 1.2.3'

    developer.run_license_finder
    expect(developer).to be_seeing 'manual_dep, 1.2.3, MIT'
  end

  specify 'can be simultaneously approved' do
    developer.execute_command 'license_finder dependencies add --approve manual Whatever'

    developer.run_license_finder
    expect(developer).not_to be_seeing 'manual_dep'
  end

  specify 'can be simultaneously homepaged' do
    developer.execute_command 'license_finder dependencies add manual Whatever --homepage=some-homepage'

    developer.run_license_finder(nil, '--columns="name" "homepage"')
    expect(developer).to be_seeing 'manual, some-homepage'
  end

  specify 'appear in the CLI' do
    developer.execute_command 'license_finder dependencies add manual_dep Whatever'
    expect(developer).to be_seeing 'manual_dep'

    developer.execute_command 'license_finder dependencies list'
    expect(developer).to be_seeing 'manual_dep'

    developer.execute_command 'license_finder dependencies remove manual_dep'
    developer.execute_command 'license_finder dependencies list'
    expect(developer).to_not be_seeing 'manual_dep'
  end

  specify 'does not report dependencies that are manually removed' do
    developer.create_empty_project
    developer.execute_command('license_finder dependencies add test_gem Random_License 0.0.1')

    developer.run_license_finder

    expect(developer).to be_receiving_exit_code(1)
    expect(developer).to be_seeing 'test_gem'

    developer.execute_command('license_finder dependencies remove test_gem')

    developer.run_license_finder

    expect(developer).to be_receiving_exit_code(0)
    expect(developer).not_to be_seeing 'test_gem'
  end
end
