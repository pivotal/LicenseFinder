Given(/^I have an app with license finder that depends on a gem with license and version details$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
  @user.add_dependency_to_app('info_gem', license: 'MIT', version: '1.1.1')
end

Then(/^I should see those version and license details in the dependencies\.txt file$/) do
  File.read(@user.app_path("doc/dependencies.txt")).should include "info_gem, 1.1.1, MIT"
end
