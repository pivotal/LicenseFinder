Given(/^I have an app with license finder that depends on a GPL licensed gem in the test bundler group$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
  @user.add_dependency_to_app 'gpl_gem', :license => 'GPL', :bundler_groups => 'test'
end

And(/^I ignore the test group$/) do
  @user.configure_license_finder_bundler_ignore_groups('test')
end

Then(/^I should not see the GPL licensed gem in the output$/) do
  @output.should_not include 'gpl_gem'
end

When(/^I get the ignored groups from the command line$/) do
  @output = @user.execute_command('license_finder ignored_bundler_group list')
end

Then(/^I should see the test group in the output$/) do
  @output.should include 'test'
end
