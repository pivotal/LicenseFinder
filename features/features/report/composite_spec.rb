require_relative '../../support/feature_helper'

describe 'Composite project' do
  # As a non-technical product owner
  # I want to run license finder on a composite project
  # So that I can easily review all licenses used by sub-projects

  let(:developer) { LicenseFinder::TestingDSL::User.new }

  specify 'shows dependencies for all active projects' do
    LicenseFinder::TestingDSL::CompositeProject.create
    developer.execute_command('license_finder report --recursive')
    expect(developer).to be_seeing('junit,4.11,Common Public License Version 1.0')
  end
end
