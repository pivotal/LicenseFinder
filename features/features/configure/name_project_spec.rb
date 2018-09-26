# frozen_string_literal: true

require_relative '../../support/feature_helper'

describe 'Project name' do
  # As a developer
  # I want to assign a name for my project
  # So that product owners see it in the reports

  let(:developer) { LicenseFinder::TestingDSL::User.new }
  let(:product_owner) { LicenseFinder::TestingDSL::User.new }

  before { developer.create_empty_project }

  specify 'appears in the HTML report' do
    developer.execute_command 'license_finder project_name add changed_name'

    expect(product_owner.view_html).to be_titled 'changed_name'
  end

  specify 'defaults to the directory name' do
    expect(product_owner.view_html).to be_titled 'my_app'
  end

  specify 'appears in the CLI' do
    developer.execute_command 'license_finder project_name add my_proj'
    expect(developer).to be_seeing 'my_proj'
    developer.execute_command 'license_finder project_name show'
    expect(developer).to be_seeing 'my_proj'

    developer.execute_command 'license_finder project_name remove'
    developer.execute_command 'license_finder project_name show'
    expect(developer).to_not be_seeing 'my_proj'
  end
end
