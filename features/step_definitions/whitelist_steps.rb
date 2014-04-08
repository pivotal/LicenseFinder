Given(/^I have an app with license finder that depends on an MIT license$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem 'mit_gem', :license => 'MIT'
end

Given(/^I have an app with license finder that depends on an BSD license$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem 'bsd_gem', :license => 'BSD'
end

When(/^I whitelist the BSD license$/) do
  @user.execute_command 'license_finder whitelist add BSD'
end

When(/^I whitelist the Expat license$/) do
  @user.execute_command 'license_finder whitelist add Expat'
end

When(/^I view the whitelisted licenses$/) do
  @output = @user.execute_command 'license_finder whitelist list'
end

When(/^I remove Expat from the whitelist$/) do
  @output = @user.execute_command 'license_finder whitelist remove Expat'
end

Then(/^I should not see a MIT licensed gem unapproved$/) do
  @output = @user.execute_command 'license_finder --quiet'
  @output.should_not include 'mit_gem'
end

Then(/^I should see Expat in the output$/) do
  @output.should include 'Expat'
end

Then(/^I should not see Expat in the output$/) do
  @output.should_not include 'Expat'
end

Then(/^I should not see a BSD licensed gem unapproved$/) do
  @output = @user.execute_command 'license_finder --quiet'
  @output.should_not include 'bsd_gem'
end
