Given(/^I have an app that depends on a GPL licensed gem$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem "gpl_gem", license: "GPL"
end

When(/^I approve that gem$/) do
  @user.execute_command "license_finder"
  @user.should be_seeing "gpl_gem"
  @user.execute_command "license_finder approve gpl_gem --approver 'Julian' --message 'We really need this'"
  @user.execute_command "license_finder --quiet"
end

Then(/^I should not see that gem in the console output$/) do
  @user.should_not be_seeing "gpl_gem"
end

Then(/^I should see that gem approved in dependencies\.html$/) do
  @user.in_gem_html("gpl_gem") do |gpl_gem|
    gpl_gem[:class].split(' ').should include "approved"
    gpl_gem.should have_content "Julian"
    gpl_gem.should have_content "We really need this"
  end
end
