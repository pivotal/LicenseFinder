Given(/^I have an app that depends on a few gems without known licenses$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem 'other_gem', version: '1.0', license: 'other'
  @user.create_and_depend_on_gem 'control_gem', version: '1.0', license: 'other'
end

When(/^I set one gem's license to MIT from the command line$/) do
  @user.execute_command 'license_finder --quiet'
  @user.execute_command 'license_finder license MIT other_gem'
  @user.execute_command 'license_finder --quiet'
end

Then(/^I should see that gem's license set to MIT$/) do
  @user.should be_seeing 'other_gem, 1.0, MIT'
end

Then(/^I should see other gems have not changed their licenses$/) do
  @user.should be_seeing 'control_gem, 1.0, other'
end

Given(/^I have an app that depends on a manually licensed gem$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem 'changed_gem', :license => 'MIT'
  @user.execute_command "license_finder --quiet"
  @user.execute_command "license_finder license Ruby changed_gem"
  @user.should be_seeing_something_like /changed_gem.*Ruby/
end

Then(/^the gem should keep its manually assigned license$/) do
  @user.should be_seeing_something_like /changed_gem.*ruby/
end

