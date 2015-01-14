require 'feature_helper'

describe "CSV report" do
  # As a non-technical application product owner
  # I want license finder to generate an easy-to-understand text report
  # So that I can quickly review my application dependencies and licenses

  let(:user) { LicenseFinder::TestingDSL::User.new }

  specify "shows dependency data in CSV form" do
    user.create_empty_project
    user.execute_command 'license_finder dependencies add info_gem BSD 1.1.1'

    user.execute_command('license_finder report --format csv --columns approved name version licenses')
    expect(user).to be_seeing "Not approved,info_gem,1.1.1,BSD"
  end
end
