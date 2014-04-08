Given(/^I have an app that has no config directory$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  path = @user.config_path
  path.rmtree if path.exist?
  path.should_not be_exist
end

Given(/^I have an app with an unapproved dependency$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
  @user.create_and_depend_on_gem 'unapproved_gem', :license => 'MIT'
end

When(/^I run license_finder help on a specific command$/) do
  @output = @user.execute_command "license_finder ignored_bundler_groups help add"
end

When(/^I run license_finder help$/) do
  @output = @user.execute_command "license_finder help"
end

Then(/^it creates a config directory with the license_finder config$/) do
  @user.config_path.should be_exist
  text = "---\nwhitelist:\n#- MIT\n#- Apache 2.0\nignore_groups:\n#- test\n#- development\ndependencies_file_dir: './doc/'\nproject_name: # project name\n"
  @user.config_file.read.should == text.gsub(/^\s+/, "")
end

Then /^it should exit with status code (\d)$/ do |status|
  $?.exitstatus.should == status.to_i
end

Then(/^should list my unapproved dependency in the output$/) do
  @output.should include 'unapproved_gem'
end

Then(/^I should see all dependencies approved for use$/) do
  @output.should include 'All dependencies are approved for use'
end

Then(/^I should see the correct subcommand usage instructions$/) do
  @output.should include 'license_finder ignored_bundler_groups add GROUP'
end

Then(/^I should the correct default usage instructions$/) do
  @output.should include 'license_finder help [COMMAND]'
end
