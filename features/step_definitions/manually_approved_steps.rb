Given(/^I have an app that depends on a GPL licensed gem$/) do
  @user = LicenseFinder::TestingDSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem "gpl_gem", license: "GPL"
end

When(/^I approve that gem$/) do
  @user.run_license_finder
  expect(@user).to be_seeing "gpl_gem"
  @user.execute_command "license_finder approval add gpl_gem --who 'Julian' --why 'We really need this'"
  @user.run_license_finder
end

Then(/^I should not see that gem in the console output$/) do
  expect(@user).to_not be_seeing "gpl_gem"
end

Then(/^I should see that gem approved in dependencies\.html$/) do
  @user.in_gem_html("gpl_gem") do |gpl_gem|
    expect(gpl_gem[:class].split(' ')).to include "approved"
    expect(gpl_gem).to have_content "Julian"
    expect(gpl_gem).to have_content "We really need this"
  end
end
