require 'feature_helper'

describe "CSV report" do
  # As a non-technical application product owner
  # I want license finder to generate a csv report
  # So that I can easily review my application dependencies and licenses

  let(:developer) { LicenseFinder::TestingDSL::User.new }
  let(:product_owner) { LicenseFinder::TestingDSL::User.new }

  specify "shows dependency data in CSV form" do
    developer.create_empty_project
    developer.execute_command 'license_finder dependencies add info_gem BSD 1.1.1'

    product_owner.execute_command('license_finder report --format csv --columns approved name version licenses')
    expect(product_owner).to be_seeing "Not approved,info_gem,1.1.1,BSD"
  end
end
