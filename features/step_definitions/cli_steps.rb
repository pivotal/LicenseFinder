Given(/^I have an app with license finder that has no config directory$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
  path = @user.app_path('config')
  FileUtils.rm_rf(path)
  File.should_not be_exists(path)
end

Given(/^I have an app with license finder that depends on a MIT licensed gem$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
  @user.add_dependency_to_app 'mit_gem', :license => 'MIT'
end

Given(/^I have a project that depends on mime\-types with a manual license type$/) do
  @user = ::DSL::User.new
  @user.create_rails_app
  @user.add_gem_dependency('mime-types')
  @user.bundle_app
  @user.execute_command "license_finder --quiet"
  @output = @user.execute_command "license_finder license Ruby mime-types"
  @output.should =~ /mime-types.*Ruby/
end

When(/^I run license_finder help on a specific command$/) do
  @output = @user.execute_command "license_finder ignored_bundler_groups help add"
end

When(/^I run license_finder help$/) do
  @output = @user.execute_command "license_finder help"
end

Then(/^it creates a config directory with the license_finder config$/) do
  File.should be_exists(@user.app_path('config'))
  text = "---\nwhitelist:\n#- MIT\n#- Apache 2.0\nignore_groups:\n#- test\n#- development\ndependencies_file_dir: './doc/'\nproject_name: # project name\n"
  File.read(@user.app_path('config/license_finder.yml')).should == text.gsub(/^\s+/, "")
end

Then /^it should exit with status code (\d)$/ do |status|
  $?.exitstatus.should == status.to_i
end

Then(/^should list my MIT gem in the output$/) do
  @output.should include 'mit_gem'
end

Then(/^I should see all dependencies approved for use$/) do
  @output.should include 'All dependencies are approved for use'
end

Then(/^the mime\-types license remains set with my manual license type$/) do
  @output.should =~ /mime-types.*ruby/
end

Then(/^I should see the correct subcommand usage instructions$/) do
  @output.should include 'license_finder ignored_bundler_groups add GROUP'
end

Then(/^I should the correct default usage instructions$/) do
  @output.should include 'license_finder help [COMMAND]'
end
