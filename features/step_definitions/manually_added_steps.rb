Given(/^I have an app and a JS dependency$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.execute_command 'license_finder dependencies add MIT my_js_dep 1.2.3'
end

When(/^I add my JS dependency$/) do
  @user.execute_command 'license_finder dependencies add MIT my_js_dep 1.2.3'
end

When(/^I add my JS dependency with an approval flag$/) do
  @user.execute_command 'license_finder dependencies add --approve MIT my_js_dep 1.2.3'
  @user.should be_seeing "The my_js_dep dependency has been added and approved"
end

When(/^I remove my JS dependency$/) do
  @user.execute_command 'license_finder dependencies remove my_js_dep'
end

Then(/^I should see the JS dependency in the console output$/) do
  @user.execute_command 'license_finder --quiet'
  @user.should be_seeing 'my_js_dep, 1.2.3, MIT'
end

Then(/^I should not see the JS dependency in the console output$/) do
  @user.execute_command 'license_finder --quiet'
  @user.should_not be_seeing 'my_js_dep, 1.2.3, MIT'
end
