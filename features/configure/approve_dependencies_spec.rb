require 'feature_helper'

describe "Manually Approved Dependencies" do
  # As a developer
  # I want to approve dependencies that do not have whitelisted licenses
  # So that I can track the dependencies which my business has approved

  let(:user) { LicenseFinder::TestingDSL::User.new }

  before do
    user.create_empty_project
    user.execute_command 'license_finder dependencies add manual_dep MIT 1.2.3'
    user.execute_command "license_finder approval add manual_dep --who 'Julian' --why 'We really need this'"
  end

  specify "do not appear in action items" do
    user.run_license_finder
    expect(user).to_not be_seeing "manual_dep"
  end

  specify "include approval detail in reports" do
    user.execute_command 'license_finder report --format html'

    user.in_dep_html("manual_dep") do |manual_dep|
      expect(manual_dep[:class].split(' ')).to include "approved"
      expect(manual_dep).to have_content "Julian"
      expect(manual_dep).to have_content "We really need this"
    end
  end
end
