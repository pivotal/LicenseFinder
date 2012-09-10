require 'fileutils'

Given /^I have a rails application with license finder$/ do
  @user = DSL::User.new
  @user.create_rails_app
end

Given /^I have an application with license finder$/ do
  @user = DSL::User.new
  @user.create_nonrails_app
end

Given /^my application does not have a config directory$/ do
  FileUtils.rm_rf(@user.config_location)
  File.exists?(@user.config_location).should be_false
end

Then /^the config directory should exist$/ do
  File.exists?(@user.config_location).should be_true
end

Given /^my application's rake file requires license finder$/ do
  @user.add_to_rakefile "require 'bundler/setup'"
  @user.add_to_rakefile "require 'license_finder'"
  @user.add_to_rakefile "LicenseFinder.load_rake_tasks"
end

Given /^my rails app depends on a gem "(.*?)" licensed with "(.*?)"$/ do |gem_name, license|
  @user.add_dependency_to_app gem_name, license
end

Given /^I whitelist the "(.*?)" license$/ do |license|
  @user.configure_license_finder_whitelist [license]
end

Given /^I whitelist the following licenses: "([^"]*)"$/ do |licenses|
  @user.configure_license_finder_whitelist licenses.split(", ")
end

When /^I run "(.*?)"$/ do |command|
  @output = @user.execute_command command
end

When /^I replace that content with the following content in "([^"]*)":$/ do |filename, text|
  @user.edit_file(filename, replace_this: @content, with: text)
end

When /^I add the following content to "([^"]*)":$/ do |filename, text|
  @user.append_to_file(filename, @content = text)
end

Then /^I should see "(.*?)" in its output$/ do |gem_name|
  @output.should include gem_name
end

Then /^I should not see "(.*?)" in its output$/ do |gem_name|
  @output.should_not include gem_name
end

Then /^license finder should generate a file "([^"]*)" with the following content:$/ do |filename, text|
  File.read(File.join(@user.app_location, filename)).should == text.gsub(/^\s+/, "")
end

Then /^license finder should generate a file "([^"]*)" that includes the following content:$/ do |filename, text|
  @content = text
  file = File.read(File.join(@user.app_location, filename))
  file.should include @content
end

Then /^it should exit with status code (\d)$/ do |status|
  $?.exitstatus.should == status.to_i
end


module DSL
  class User
    def create_nonrails_app
      reset_sandbox!

      `cd tmp && bundle gem #{app_name}`

      Bundler.with_clean_env do
        `cd #{app_location} && echo \"gem 'rake'\" >> Gemfile `
      end

      Bundler.with_clean_env do
        `cd #{app_location} && echo \"gem 'license_finder', path: '../../'\" >> Gemfile`
      end
    end

    def create_rails_app
      reset_sandbox!

      `bundle exec rails new #{app_location} --skip-bundle`

      Bundler.with_clean_env do
        `cd #{app_location} && echo \"gem 'license_finder', path: '../../'\" >> Gemfile`
      end
    end

    def edit_file(filename, options={})
      replace_this = options.fetch :replace_this
      with = options.fetch :with

      file_contents = File.read(File.join(app_location, filename))

      file_contents[replace_this] = with

      File.open(File.join(app_location, filename), "w") do |f|
        f.puts file_contents
      end
    end

    def append_to_file(filename, text)
      File.open(File.join(app_location, filename), "a") do |f|
        f.puts text
      end
    end

    def add_to_rakefile(line)
      `echo \"#{line}\" >> #{app_location}/Rakefile`
    end

    def add_dependency_to_app(gem_name, license)
      `mkdir #{sandbox_location}/#{gem_name}`

      File.open("#{sandbox_location}/#{gem_name}/#{gem_name}.gemspec", 'w') do |file|
        file.write <<-GEMSPEC
          Gem::Specification.new do |s|
            s.name = "#{gem_name}"
            s.version = "0.0.0"
            s.author = "Cucumber"
            s.summary = "Gem for testing License Finder"
            s.license = "#{license}"
          end
        GEMSPEC
      end

      Bundler.with_clean_env do
        `cd #{app_location} && echo \"gem '#{gem_name}', path: '../#{gem_name}'\" >> Gemfile && bundle`
      end
    end

    def configure_license_finder_whitelist(whitelisted_licenses=[])
      File.open("#{app_location}/config/license_finder.yml", "w") do |f|
        f.write <<-YML
---
whitelist:
#{whitelisted_licenses.map {|l| "- #{l}"}.join("\n")}
YML
      end
    end

    def execute_command(command)
      Bundler.with_clean_env do
        @output = `cd #{app_location} && bundle exec #{command}`
      end

      @output
    end

    def app_location
      File.join(sandbox_location, app_name)
    end

    def config_location
      File.join(app_location, 'config')
    end

    private
    def app_name
      "my_app"
    end

    def sandbox_location
      "tmp"
    end

    def reset_sandbox!
      `rm -rf #{sandbox_location}`
      `mkdir #{sandbox_location}`
    end
  end
end
