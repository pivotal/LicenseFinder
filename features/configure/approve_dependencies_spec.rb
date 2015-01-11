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

    html = user.view_html
    expect(html).to be_approved 'manual_dep'

    html.in_dep("manual_dep") do |section|
      expect(section).to have_content "Julian"
      expect(section).to have_content "We really need this"
    end
  end
end
