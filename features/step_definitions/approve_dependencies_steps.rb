Given(/^I have an app with license finder that depends on a GPL licensed gem$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
  @user.add_dependency_to_app "gpl_gem", :license => "GPL"
end

When(/^I approve that gem$/) do
  @output = @user.execute_command "license_finder"
  @output.should include "gpl_gem"
  @output = @user.execute_command "license_finder approve gpl_gem"
  @output = @user.execute_command "license_finder --quiet"
end

Then(/^I should not see that gem in the console output$/) do
  @output.should_not include "gpl_gem"
end

Then(/^I should see that gem approved in dependencies\.html$/) do
  gem_name = "gpl_gem"
  css_class = "approved"
  html = File.read(@user.dependencies_html_path)
  page = Capybara.string(html)
  gpl_gem = page.find("##{gem_name}")
  gpl_gem[:class].should == css_class
end
