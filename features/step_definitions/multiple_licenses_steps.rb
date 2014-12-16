Given(/^I have an app that depends on BSD and GPL-2 licenses$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem 'bsd_and_gpl2_gem', licenses: %w(BSD GPL-2)
end

When(/^I whitelist the GPL-2 license$/) do
  @user.execute_command 'license_finder whitelist add GPL-2'
end

Then(/^I should not see a BSD and GPL-2 licensed gem unapproved$/) do
  @user.run_license_finder
  expect(@user).to_not be_seeing 'bsd_and_gpl2_gem'
end
