require 'feature_helper'

describe "Project name" do
  # As a developer
  # I want to assign a name for my project
  # So that the reports show it

  let(:user) { LicenseFinder::TestingDSL::User.new }

  before { user.create_empty_project }

  specify "appears in the HTML report" do
    user.execute_command 'license_finder project_name add changed_name'

    user.execute_command 'license_finder report --format html'
    expect(user.view_html).to be_has_title 'changed_name'
  end

  specify "defaults to the directory name" do
    user.execute_command 'license_finder report --format html'

    expect(user.view_html).to be_has_title 'my_app'
  end

  specify "appears in the CLI" do
    user.execute_command 'license_finder project_name add my_proj'
    expect(user).to be_seeing 'my_proj'
    user.execute_command 'license_finder project_name show'
    expect(user).to be_seeing 'my_proj'

    user.execute_command 'license_finder project_name remove'
    user.execute_command 'license_finder project_name show'
    expect(user).to_not be_seeing 'my_proj'
  end
end
