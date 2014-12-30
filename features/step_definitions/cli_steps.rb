Given(/^I have an app that has no config directory$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  path = @user.config_path
  path.rmtree if path.exist?
  expect(path).to_not be_exist
end

Given(/^I have an app with an unapproved dependency$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem 'unapproved_gem', license: 'MIT'
end

When(/^I run license_finder help on a specific command$/) do
  @user.execute_command "license_finder ignored_groups help add"
end

When(/^I run license_finder help$/) do
  @user.execute_command "license_finder help"
end

Then(/^it creates a config directory with the license_finder config$/) do
  expect(@user.config_path).to be_exist
  text = %|---\ndependencies_file_dir: './doc/'\n|
  expect(@user.config_file.read).to eq(text.gsub(/^\s+/, ""))
end

Then /^it should exit with status code (\d)$/ do |status|
  expect($last_command_exit_status.exitstatus).to eq(status.to_i)
end

Then(/^should list my unapproved dependency in the output$/) do
  expect(@user).to be_seeing 'unapproved_gem'
end

Then(/^I should see all dependencies approved for use$/) do
  expect(@user).to be_seeing 'All dependencies are approved for use'
end

Then(/^I should see the correct subcommand usage instructions$/) do
  expect(@user).to be_seeing 'license_finder ignored_groups add GROUP'
end

Then(/^I should see the default usage instructions$/) do
  expect(@user).to be_seeing 'license_finder help [COMMAND]'
end

Then(/^I should see License Finder has the MIT license$/) do
  expect(@user).to be_seeing_something_like /license_finder.*MIT/
end
