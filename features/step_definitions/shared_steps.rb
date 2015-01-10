require './features/step_definitions/testing_dsl'

Given(/^I have an app$/) do
  @user = LicenseFinder::TestingDSL::User.new
  @user.create_ruby_app
end

When(/^I run license_finder$/) do
  @user.run_license_finder
end

When(/^I whitelist everything I can think of$/) do
  whitelist = ["MIT","unknown","New BSD","Apache 2.0","Ruby"]
  @user.configure_license_finder_whitelist whitelist
  @user.run_license_finder
end

Then(/^I should see the project name (\w+) in the html$/) do |project_name|
  expect(@user.html_title).to have_content project_name
end
