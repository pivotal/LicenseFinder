Given(/^I have an app that depends on a gem with license and version details$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem('info_gem', license: 'MIT', version: '1.1.1')
end

Then(/^I should see those version and license details in the text report$/) do
  @user.execute_command('license_finder report')
  expect(@user).to be_seeing "info_gem,1.1.1,MIT"
end
