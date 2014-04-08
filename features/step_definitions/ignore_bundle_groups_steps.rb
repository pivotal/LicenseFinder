Given(/^I have an app with license finder that depends on a GPL licensed gem in the test bundler group$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_gem 'gpl_gem', :license => 'GPL'
  @user.depend_on_gem 'gpl_gem', :bundler_group => 'test'
end

When(/^I add the test group to the ignored bundler groups$/) do
  @user.execute_command('license_finder ignored_bundler_group add test')
end

When(/^I remove the test group from the ignored bundler groups$/) do
  @user.execute_command('license_finder ignored_bundler_group remove test')
end

When(/^I get the ignored groups$/) do
  @output = @user.execute_command('license_finder ignored_bundler_group list')
end

Then(/^I should not see the GPL licensed gem in the output$/) do
  @output.should_not include 'gpl_gem'
end

Then(/^I should see the test group in the output$/) do
  @output.should include 'test'
end

Then(/^I should not see the test group in the output$/) do
  @output.should_not include 'test'
end
