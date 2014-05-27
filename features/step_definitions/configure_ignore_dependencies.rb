Given(/^I have an app that depends on bundler$/) do
  @user = ::DSL::User.new
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

Then(/^the generated dependencies do not contain bundler$/) do
  expect(@user).not_to be_seeing 'bundler_faker'
end

Then(/^I should not see 'bundler' in the dependency docs$/)do
  @user.execute_command('license_finder') 
  dependencies_csv_path =  @user.app_path.join('doc', 'dependencies.csv')
  dependencies_csv = File.open(dependencies_csv_path, 'r')

  expect(dependencies_csv.read).not_to match /bundler_faker/
end

