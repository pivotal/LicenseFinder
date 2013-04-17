Given(/^I have an app with license finder that depends on an other licensed gem$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
  @user.add_license_finder_to_rakefile
  @user.add_dependency_to_app 'other_gem', :license => 'other'
end

When(/^I set that gems license to MIT from the command line$/) do
  @output = @user.execute_command 'license_finder -q'
  @output = @user.execute_command 'license_finder -q license MIT other_gem'
  @output = @user.execute_command 'license_finder -q'
end

Then(/^I should see that other gems license set to MIT$/) do
  @output.should include 'other_gem'
end
