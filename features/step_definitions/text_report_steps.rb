Given(/^I have an app with license finder that depends on a gem with license and version details$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
  @user.add_dependency_to_app('info_gem', license: 'MIT', version: '1.1.1')
end

Given(/^I have a dependencies\.txt file$/) do
  Dir.mkdir(@user.app_path("doc"))
  File.open(@user.app_path("doc/dependencies.txt"), 'w+') { |file| file.puts("Legacy text file") }
end

Then(/^I should see those version and license details in the dependencies\.csv file$/) do
  File.read(@user.app_path("doc/dependencies.csv")).should include "info_gem, 1.1.1, MIT"
end

Then(/^I should see dependencies\.txt replaced by dependencies\.csv$/) do
  File.exists?(@user.app_path("doc/dependencies.txt")).should be_false
  File.exists?(@user.app_path("doc/dependencies.csv")).should be_true
end
