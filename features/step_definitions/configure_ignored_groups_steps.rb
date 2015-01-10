Given(/^I have an app that depends on a gem in the test group$/) do
  @user = LicenseFinder::TestingDSL::User.new
  @user.create_ruby_app
  @user.create_gem 'gpl_gem', license: 'GPL'
  @user.depend_on_local_gem 'gpl_gem', groups: ['test']
end

When(/^I ignore the test group$/) do
  @user.execute_command('license_finder ignored_groups add test')
end

When(/^I stop ignoring the test group$/) do
  @user.execute_command('license_finder ignored_groups remove test')
end

When(/^I get the ignored groups$/) do
  @user.execute_command('license_finder ignored_groups list')
end

Then(/^I should not see the test gem in the output$/) do
  expect(@user).to_not be_seeing 'gpl_gem'
end

Then(/^I should see the test group in the output$/) do
  expect(@user).to be_seeing 'test'
end

Then(/^I should not see the test group in the output$/) do
  expect(@user).to_not be_seeing 'test'
end
