require 'feature_helper'

describe "Manually Approved Dependencies" do
  # As a developer
  # I want to approve dependencies that do not have whitelisted licenses
  # So that I can track the dependencies which my business has approved

  let(:developer) { LicenseFinder::TestingDSL::User.new }
  let(:product_owner) { LicenseFinder::TestingDSL::User.new }

  before do
    developer.create_empty_project
    developer.execute_command 'license_finder dependencies add manual_dep MIT 1.2.3'
    developer.execute_command "license_finder approval add manual_dep --who 'Julian' --why 'We really need this'"
  end

  specify "do not appear in action items" do
    developer.run_license_finder
    expect(developer).to_not be_seeing "manual_dep"
  end

  specify "include approval detail in reports" do
    html = product_owner.view_html
    expect(html).to be_approved 'manual_dep'

    html.in_dep("manual_dep") do |section|
      expect(section).to have_content "Julian"
      expect(section).to have_content "We really need this"
    end
  end
end
