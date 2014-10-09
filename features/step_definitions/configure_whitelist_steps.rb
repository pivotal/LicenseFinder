Given(/^I have an app that depends on an MIT license$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem 'mit_gem', license: 'MIT'
end

Given(/^I have an app that depends on an BSD license$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem 'bsd_gem', license: 'BSD'
end

When(/^I whitelist the BSD license$/) do
  @user.execute_command 'license_finder whitelist add BSD'
end

When(/^I whitelist the Expat license$/) do
  @user.execute_command 'license_finder whitelist add Expat'
end

When(/^I view the whitelisted licenses$/) do
  @user.execute_command 'license_finder whitelist list'
end

When(/^I remove Expat from the whitelist$/) do
  @user.execute_command 'license_finder whitelist remove Expat'
end

Then(/^I should not see a MIT licensed gem unapproved$/) do
  @user.execute_command 'license_finder --quiet'
  expect(@user).to_not be_seeing 'mit_gem'
end

Then(/^I should see Expat in the output$/) do
  expect(@user).to be_seeing 'Expat'
end

Then(/^I should not see Expat in the output$/) do
  expect(@user).to_not be_seeing 'Expat'
end

Then(/^I should not see a BSD licensed gem unapproved$/) do
  @user.execute_command 'license_finder --quiet'
  expect(@user).to_not be_seeing 'bsd_gem'
end
