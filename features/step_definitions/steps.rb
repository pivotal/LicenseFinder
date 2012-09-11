require 'fileutils'

Given /^I have a rails application with license finder$/ do
  @user = DSL::User.new
  @user.create_rails_app
end

Given /^I have an application with license finder$/ do
  @user = DSL::User.new
  @user.create_nonrails_app
end


Given /^I have an application setup with rake and license finder$/ do
  @user = DSL::User.new
  @user.create_nonrails_app
  @user.add_license_finder_to_rakefile
  @user.execute_command "rake license:init"
end

Given /^my application does not have a config directory$/ do
  FileUtils.rm_rf(@user.config_path)
  File.exists?(@user.config_path).should be_false
end

Then /^the config directory should exist$/ do
  File.exists?(@user.config_path).should be_true
end

Given /^my application's rake file requires license finder$/ do
  @user.add_license_finder_to_rakefile
end

Given /^my (?:rails )?app depends on a gem "(.*?)" licensed with "(.*?)"$/ do |gem_name, license|
  @user.add_dependency_to_app gem_name, license
end

Given /^my rails app depends on a gem "(.*?)" licensed with "(.*?)" in the "(.*?)" bundler groups$/ do |gem_name, license, bundler_groups|
  @user.add_dependency_to_app gem_name, license, bundler_groups
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

When /^I update the settings for "([^"]*)" with the following content:$/ do |gem, text|
  @user.update_gem(gem, YAML.load(text))
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
  File.read(File.join(@user.app_path, filename)).should == text.gsub(/^\s+/, "")
end

Then /^license finder should generate a file "([^"]*)" containing:$/ do |filename, text|
  File.read(File.join(@user.app_path, filename)).should include(text.gsub(/^\s+/, ""))
end

Then /^I should see the following settings for "([^"]*)":$/ do |name, yaml|
  expected_settings = YAML.load(yaml)
  all_settings = YAML.load(File.read(@user.dependencies_file_path))
  actual_settings = all_settings.detect { |gem| gem['name'] == name }

  actual_settings.should include expected_settings
end

Then /^it should exit with status code (\d)$/ do |status|
  $?.exitstatus.should == status.to_i
end


module DSL
  class User
    def create_nonrails_app
      reset_projects!

      `cd #{projects_path} && bundle gem #{app_name}`

      Bundler.with_clean_env do
        `cd #{app_path} && echo \"gem 'rake'\" >> Gemfile`
      end

      Bundler.with_clean_env do
        `cd #{app_path} && echo \"gem 'license_finder', path: '#{root_path}'\" >> Gemfile`
      end
    end

    def add_license_finder_to_rakefile
      add_to_rakefile <<-RUBY
        require 'bundler/setup'
        require 'license_finder'
        LicenseFinder.load_rake_tasks
      RUBY
    end

    def create_rails_app
      reset_projects!

      `bundle exec rails new #{app_path} --skip-bundle`

      Bundler.with_clean_env do
        `cd #{app_path} && echo \"gem 'license_finder', path: '#{root_path}'\" >> Gemfile`
      end

      bundle_app
    end

    def update_gem(name, attrs)
      file_contents = YAML.load(File.read(dependencies_file_path))

      index = file_contents.index { |gem| gem['name'] == name }
      file_contents[index].merge!(attrs)

      File.open(dependencies_file_path, "w") do |f|
        f.puts file_contents.to_yaml
      end
    end

    def append_to_file(filename, text)
      File.open(File.join(app_path, filename), "a") do |f|
        f.puts text
      end
    end

    def add_to_rakefile(line)
      `echo \"#{line}\" >> #{app_path}/Rakefile`
    end

    def add_dependency_to_app(gem_name, license, bundler_groups = "")
      bundler_groups = bundler_groups.split(',').map(&:strip)

      `mkdir #{projects_path}/#{gem_name}`

      File.open("#{projects_path}/#{gem_name}/#{gem_name}.gemspec", 'w') do |file|
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

      gemfile_bits = []
      gemfile_bits << "gem '#{gem_name}'"
      gemfile_bits << "path: '#{File.join(projects_path, gem_name)}'"
      gemfile_bits << "groups: #{bundler_groups.to_s.tr('\"', '\'')}" if bundler_groups.size > 1
      gemfile_bits << "group: '#{bundler_groups.first}'" if bundler_groups.size == 1

      system "cd #{app_path} && echo \"#{gemfile_bits.join(", ")} \" >> Gemfile"

      bundle_app
    end

    def configure_license_finder_whitelist(whitelisted_licenses=[])
      File.open("#{app_path}/config/license_finder.yml", "w") do |f|
        f.write({
          'whitelist' => whitelisted_licenses
        }.to_yaml)
      end
    end

    def execute_command(command)
      Bundler.with_clean_env do
        @output = `cd #{app_path} && bundle exec #{command}`
      end

      @output
    end

    def app_path
      File.join(projects_path, app_name)
    end

    def config_path
      File.join(app_path, 'config')
    end

    def dependencies_file_path
      File.join(app_path, 'dependencies.yml')
    end

    private

    def bundle_app
      Bundler.with_clean_env do
        `bundle install --gemfile=#{app_path}/Gemfile --path=#{bundle_path} #{'--local' unless bundle_remote?}`
        mark_as_bundled if $?.success?
      end
    end

    def app_name
      "my_app"
    end

    def sandbox_path
      File.join(root_path, "tmp")
    end

    def projects_path
      File.join(sandbox_path, "projects")
    end

    def bundle_path
      File.join(sandbox_path, "bundle")
    end

    def reset_projects!
      `rm -rf #{projects_path}`
      `mkdir -p #{projects_path}`
    end

    def bundle_remote?
      ENV['LF_BUNDLE_REMOTE'] == 'true' || !File.exists?(bundled_flag)
    end

    def bundled_flag
      File.join(sandbox_path, ".bundled")
    end

    def mark_as_bundled
      `touch #{bundled_flag}`
    end

    def root_path
      File.realpath(File.join(File.dirname(__FILE__), "..", ".."))
    end
  end
end
