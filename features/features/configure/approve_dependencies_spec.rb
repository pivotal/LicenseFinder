# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Manually Approved Dependencies' do
  # As a developer
  # I want to approve dependencies without whitelisting their licenses
  # So that my business can track individual dependencies which it has approved

  let(:developer) { LicenseFinder::TestingDSL::User.new }
  let(:product_owner) { LicenseFinder::TestingDSL::User.new }

  before do
    developer.create_empty_project
    developer.execute_command 'license_finder dependencies add manual_dep MIT 1.2.3'
    developer.execute_command 'license_finder approval add manual_dep --who "Julian" --why "We really need this"'
  end

  specify 'do not appear in action items' do
    developer.run_license_finder
    expect(developer).to_not be_seeing 'manual_dep'
  end

  specify 'include approval detail in reports' do
    html = product_owner.view_html
    expect(html).to be_approved 'manual_dep'

    html.in_dep('manual_dep') do |section|
      expect(section).to have_content 'Julian'
      expect(section).to have_content 'We really need this'
    end
  end

  specify 'reports unapproved dependencies' do
    developer.create_empty_project
    developer.execute_command('license_finder dependencies add test_gem Random_License 0.0.1')
    developer.execute_command('license_finder approvals add test_gem')

    developer.run_license_finder

    expect(developer).to be_receiving_exit_code(0)
    expect(developer).not_to be_seeing 'test_gem'

    developer.execute_command('license_finder approvals remove test_gem')

    developer.run_license_finder

    expect(developer).to be_receiving_exit_code(1)
    expect(developer).to be_seeing 'test_gem'
  end

  specify 'reports only unapproved dependencies, no approved dependencies' do
    developer.create_empty_project
    developer.execute_command('license_finder dependencies add unapproved_gem Random_License 0.0.1')
    developer.execute_command('license_finder dependencies add approved_gem Random_License 0.0.1')
    developer.execute_command('license_finder approvals add approved_gem')

    developer.run_license_finder
    expect(developer).to be_receiving_exit_code(1)
    expect(developer).to be_seeing 'unapproved_gem'
    expect(developer).not_to be_seeing 'approved_gem '
  end
end
