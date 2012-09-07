Given /^I have a rails application with license finder$/ do
  @user = DSL::User.new
  @user.create_rails_app
end

Given /^my rails app depends on a gem "(.*?)" licensed with "(.*?)"$/ do |gem_name, license|
  @user.add_dependency_to_app gem_name, license
end

Given /^I whitelist the "(.*?)" license$/ do |license|
  @user.configure_license_finder_whitelist [license]
end

When /^I run "(.*?)"$/ do |command|
  @output = @user.execute_command command
end

Then /^I should see "(.*?)" in its output$/ do |gem_name|
  @output.should include gem_name
end

Then /^I should not see "(.*?)" in its output$/ do |gem_name|
  @output.should_not include gem_name
end

module DSL
  class User
    def create_rails_app
      reset_sandbox!

      `bundle exec rails new #{app_location} --skip-bundle`

      Bundler.with_clean_env do
        `pushd #{app_location} && echo \"gem 'license_finder', path: '../../'\" >> Gemfile`
      end
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
        `pushd #{app_location} && echo \"gem '#{gem_name}', path: '../#{gem_name}'\" >> Gemfile && bundle`
      end
    end

    def configure_license_finder_whitelist(whitelisted_licenses=[])
      File.open("tmp/my_app/config/license_finder.yml", "w") do |f|
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

Then /^license finder should generate a file "([^"]*)" with the following content:$/ do |filename, text|
  File.read(File.join(@user.app_location, filename)).should == text.gsub(/^\s+/, "")
end
