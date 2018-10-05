# frozen_string_literal: true

require_relative '../../support/feature_helper'
describe 'Composite project' do
  # As a non-technical product owner
  # I want to run license finder on a composite project
  # So that I can easily review all licenses used by sub-projects

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  specify 'shows dependencies for all active projects' do
    LicenseFinder::TestingDSL::CompositeProject.create
    developer.execute_command('license_finder report --recursive')
    expect(developer).to be_seeing('junit, 4.11, "Common Public License Version 1.0"')
  end

  specify 'shows csv report columns in the right order' do
    LicenseFinder::TestingDSL::CompositeProject.create
    developer.execute_command('license_finder report --recursive --format csv --columns name version install_path licenses')
    expect(developer).to be_seeing('junit,4.11,,Common Public License Version 1.0')
  end

  specify 'shows install path column when scanning recursively' do
    project = LicenseFinder::TestingDSL::BundlerProject.create
    project.install
    developer.execute_command('license_finder report --recursive --format csv --columns name version install_path licenses')
    expect(developer).to be_seeing_something_like(%r{toml,0.\d+.\d+,.*\/gems\/toml-0.\d+.\d+,MIT})
  end
end
