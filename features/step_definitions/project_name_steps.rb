When(/^I set the project name to (\w+)$/) do |project_name|
  @user.execute_command "license_finder project_name set #{project_name}"
end
