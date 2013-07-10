Given(/^I have an app with license finder that depends on an MIT license$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
  @user.add_dependency_to_app 'mit_gem', :license => 'MIT'
end

When(/^I whitelist the Expat license from the command line$/) do
  @user.execute_command 'license_finder whitelist add Expat'
end

Then(/^I should not see a MIT licensed gem unapproved$/) do
  @output = @user.execute_command 'license_finder -q'
  @output.should_not include 'mit_gem'
end

When(/^I view the whitelisted licenses from the command line$/) do
  @output = @user.execute_command 'license_finder whitelist list'
end

Then(/^I should see Expat in the output$/) do
  @output.should include 'Expat'
end
