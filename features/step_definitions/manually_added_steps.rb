Given(/^I have an app and a JS dependency$/) do
  @user = LicenseFinder::TestingDSL::User.new
  @user.create_ruby_app
  @user.execute_command 'license_finder dependencies add my_js_dep MIT 1.2.3'
end

When(/^I add my JS dependency$/) do
  @user.execute_command 'license_finder dependencies add my_js_dep MIT 1.2.3'
end

When(/^I add my JS dependency with an approval flag$/) do
  @user.execute_command 'license_finder dependencies add --approve my_js_dep MIT 1.2.3'
  expect(@user).to be_seeing "The my_js_dep dependency has been added and approved"
end

When(/^I remove my JS dependency$/) do
  @user.execute_command 'license_finder dependencies remove my_js_dep'
end

Then(/^I should see the JS dependency in the console output$/) do
  @user.run_license_finder
  expect(@user).to be_seeing 'my_js_dep, 1.2.3, MIT'
end

Then(/^I should not see the JS dependency in the console output$/) do
  @user.run_license_finder
  expect(@user).to_not be_seeing 'my_js_dep, 1.2.3, MIT'
end
