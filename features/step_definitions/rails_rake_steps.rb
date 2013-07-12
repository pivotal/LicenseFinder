Given /^I have a rails app(?:lication)? with license finder$/ do
  @user = ::DSL::User.new
  @user.create_rails_app
end

When(/^I run rake license_finder$/) do
  @output = @user.execute_command "rake license_finder --quiet"
end

Then(/^I should see a normal output$/) do
  @output.should include "Dependencies that need approval:"
end
