When(/^I set the project name to (\w+)$/) do |project_name|
  @user.execute_command "license_finder project_name add #{project_name}"
end

When(/^I remove the project name$/) do
  @user.execute_command "license_finder project_name remove"
end

When(/^I get the project name$/) do
  @user.execute_command "license_finder project_name show"
end

Then(/^I should see the project name (\w+) in the output$/) do |project_name|
  expect(@user).to be_seeing project_name
end

Then(/^I should not see the project name (\w+) in the html$/) do |project_name|
  expect(@user.html_title).not_to have_content project_name
end
