When(/^I add my JS dependency$/) do
  @output = @user.execute_command 'license_finder dependencies add MIT my_js_dep 1.2.3'
end

Then(/^I should see the JS dependency in the console output$/) do
  @output = @user.execute_command 'license_finder -q'
  @output.should include 'my_js_dep, 1.2.3, MIT'
end
