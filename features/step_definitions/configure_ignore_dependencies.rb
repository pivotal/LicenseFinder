Given(/^I have an app that depends on bundler$/) do
  @user = LicenseFinder::TestingDSL::User.new
  @user.create_ruby_app
  @user.create_gem 'bundler_faker', license: 'Whatever'
  @user.depend_on_local_gem 'bundler_faker', groups: ['test', 'development', 'production']
  @user.create_gem 'gpl_gem', license: 'GPL'
  @user.depend_on_local_gem 'gpl_gem', groups: ['test']
end

Given(/^I ignore the bundler dependency$/) do
  @user.execute_command('license_finder ignored_dependencies add bundler_faker')
end

When(/^I get the ignored dependencies$/) do
  @user.execute_command('license_finder ignored_dependencies list')
end

Then(/^I should see 'bundler' in the output$/) do
  expect(@user).to be_seeing 'bundler_faker'
end

Then(/^the bundler dependency is not listed as an action item$/) do
  @user.execute_command('license_finder > /dev/null')
  @user.execute_command('license_finder action_items')
  expect(@user).not_to be_seeing 'bundler_faker'
end

Then(/^I should not see 'bundler' in the dependency docs$/)do
  @user.run_license_finder
  @user.execute_command('license_finder report')
  expect(@user).not_to be_seeing 'bundler_faker'
end

