Given(/^I have an app with license finder that depends on an other licensed gem$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
  @user.create_and_depend_on_gem 'other_gem', version: '1.0', license: 'other'
  @user.create_and_depend_on_gem 'control_gem', version: '1.0', license: 'other'
end

When(/^I set that gems license to MIT from the command line$/) do
  @user.execute_command 'license_finder --quiet'
  @user.execute_command 'license_finder license MIT other_gem'
  @output = @user.execute_command 'license_finder --quiet'
end

Then(/^I should see that other gems license set to MIT$/) do
  @output.should include 'other_gem, 1.0, MIT'
end

Then(/^I see other licensed gems have not changed licenses$/) do
  @output.should include 'control_gem, 1.0, other'
end
