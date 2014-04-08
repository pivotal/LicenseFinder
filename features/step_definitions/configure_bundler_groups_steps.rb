Given(/^I have an app that depends on a gem in the test bundler group$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_gem 'gpl_gem', license: 'GPL'
  @user.depend_on_local_gem 'gpl_gem', groups: ['test']
end

When(/^I ignore the test group$/) do
  @user.execute_command('license_finder ignored_bundler_group add test')
end

When(/^I stop ignoring the test group$/) do
  @user.execute_command('license_finder ignored_bundler_group remove test')
end

When(/^I get the ignored groups$/) do
  @user.execute_command('license_finder ignored_bundler_group list')
end

Then(/^I should not see the test gem in the output$/) do
  @user.should_not be_seeing 'gpl_gem'
end

Then(/^I should see the test group in the output$/) do
  @user.should be_seeing 'test'
end

Then(/^I should not see the test group in the output$/) do
  @user.should_not be_seeing 'test'
end
