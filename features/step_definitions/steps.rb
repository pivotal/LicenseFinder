require 'fileutils'
require 'pathname'
require 'bundler'
require 'capybara'

Given /^I have a rails app(?:lication)? with license finder$/ do
  @user = ::DSL::User.new
  @user.create_rails_app
end

Given /^I have an app(?:lication)? with license finder$/ do
  @user = ::DSL::User.new
  @user.create_nonrails_app
end

Given /^I have an app(?:lication)? with rake and license finder$/ do
  @user = ::DSL::User.new
  @user.create_nonrails_app
  @user.add_license_finder_to_rakefile
end

Given /^my app(?:lication)? does not have a "([^"]+)" directory$/ do |name|
  path = @user.app_path(name)

  FileUtils.rm_rf(path)
  File.should_not be_exists(path)
end

Given /^my (?:rails )?app(?:lication)? depends on a gem "(.*?)" licensed with "(.*?)"$/ do |gem_name, license|
  @user.add_dependency_to_app gem_name, :license => license
end

Given /^my (?:rails )?app(?:lication)? depends on a gem "(.*?)" licensed with "(.*?)" in the "(.*?)" bundler groups$/ do |gem_name, license, bundler_groups|
  @user.add_dependency_to_app gem_name, :license => license, :bundler_groups => bundler_groups
end

Given /^I whitelist the "(.*?)" license$/ do |license|
  @user.configure_license_finder_whitelist [license]
end

Given /^I whitelist the following licenses: "([^"]*)"$/ do |licenses|
  @user.configure_license_finder_whitelist licenses.split(", ")
end

Given /^I have a legacy dependencies\.yml file with "(.*?)" approved with its "(.*?)" license$/ do |gem_name, license_name|
  @user.modifying_dependencies_file do |f|
    f.write <<-YAML
    - name: #{gem_name}
      version: 1.5.0
      license: #{license_name}
      approved: true
      notes: ''
      license_files:
      - path: /some/path/to/files/that/are/rad
    YAML
  end
end

And /^I have a legacy dependencies\.yml file with readme_files entry for gem "(.*?)"$/  do |gem_name|
  @user.modifying_dependencies_file do |f|
    f.write <<-YAML
    - name: #{gem_name}
      version: 1.5.0
      license: some_license
      approved: true
      notes: ''
      license_files:
      - path: /some/path/to/files/that/are/rad
      readme_files:
      - path: /some/path/to/files/that/are/rad/readme
    YAML
  end
end

Given /^I have a legacy dependencies\.yml file with a blank readme_files entry for gem "(.*?)"$/ do |gem_name|
  @user.modifying_dependencies_file do |f|
    f.write(<<-YAML)
    - name: #{gem_name}
      version: 1.5.0
      license: some_license
      approved: true
      notes: ''
      license_files:
      - path: /some/path/to/files/that/are/rad
      readme_files:
    YAML
  end
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

When /^my app(?:lication)? depends on a gem "([^"]*)" with:$/ do |gem_name, gem_info|
  info = gem_info.hashes.first
  @user.add_dependency_to_app(gem_name,
    :license        => info["license"],
    :summary        => info["summary"],
    :description    => info["description"],
    :version        => info["version"],
    :homepage       => info["homepage"],
    :bundler_groups => info["bundler_groups"]
  )
end

When /^the text "([^"]*)" should link to "([^"]*)"$/ do |text, link|
  html = Capybara.string File.read(@user.dependencies_html_path)
  html.all(:xpath, "//a[@href='#{link}']").first.text.should == text
end

When /^"([^"]*)" is an alternative name for the "MIT" license$/ do |alternative_name|
  # this step is simply for readability
end

When /^I whitelist the "([^"]*)" bundler group$/ do |group|
  @user.configure_license_finder_bundler_whitelist(group)
end

Then(/^I should see other_license_gem set to MIT license$/) do
  @output.should =~ /other_license_gem.*MIT/
end

Then /^I should see a "([^"]+)" directory$/ do |name|
  File.should be_exists(@user.app_path(name))
end

Then /^I should see "(.*?)" in its output$/ do |gem_name|
  @output.should include gem_name
end

Then /^I should not see "(.*?)" in its output$/ do |gem_name|
  @output.should_not include gem_name
end

Then /^I should see the file "([^"]*)" with the following content:$/ do |filename, text|
  File.read(@user.app_path(filename)).should == text.gsub(/^\s+/, "")
end

Then /^I should see the file "([^"]*)" containing:$/ do |filename, text|
  File.read(@user.app_path(filename)).should include(text.gsub(/^\s+/, ""))
end

Then /^I should see exactly one entry for "(.*?)" in "(.*?)"$/ do |gem_name, filename|
  file_contents = File.read(@user.app_path(filename))
  file_contents.scan(/#{gem_name}/).size.should == 1
end

Then /^I should not see an entry "(.*?)" for gem "(.*?)" in my dependencies\.yml$/ do |entry_key, gem_name|
  settings = YAML.load(File.read(@user.dependencies_file_path))
  gem_settings = settings.detect { |gem| gem['name'] == gem_name }
  gem_settings.should_not have_key entry_key
end

Then /^it should exit with status code (\d)$/ do |status|
  $?.exitstatus.should == status.to_i
end

Then /^I should see the "([^"]*)" in the html flagged as "([^"]*)"$/ do |gem_name, css_class|
  html = File.read(@user.dependencies_html_path)
  page = Capybara.string(html)
  gpl_gem = page.find("##{gem_name}")
  gpl_gem[:class].should == css_class
end

Then /^I should see (?:the )?"([^"]*)" in the html with the following details:$/ do |gem_name, table|
  html = File.read(@user.dependencies_html_path)
  page = Capybara.string(html)
  section = page.find("##{gem_name}")

  table.hashes.first.each do |property_name, property_value|
    section.should have_content property_value
  end
end

Then /^I should see "([^"]*)" in the html$/ do |text|
  html = File.read(@user.dependencies_html_path)
  page = Capybara.string(html)

  page.should have_content text
end

module DSL
  class User
    def create_nonrails_app
      reset_projects!

      `cd #{projects_path} && bundle gem #{app_name}`

      add_gem_dependency('rake')
      add_gem_dependency('license_finder', :path => root_path)

      bundle_app
    end

    def create_rails_app
      reset_projects!

      `bundle exec rails new #{app_path} --skip-bundle`

      add_gem_dependency('license_finder', :path => root_path)

      bundle_app
    end

    def add_license_finder_to_rakefile
      add_to_rakefile <<-RUBY
        require 'bundler/setup'
        require 'license_finder'
        LicenseFinder.load_rake_tasks
      RUBY
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

    def add_dependency_to_app(gem_name, options={})
      license = options.fetch(:license)
      summary = options.fetch(:summary, "")
      description = options.fetch(:description, "")
      bundler_groups = options.fetch(:bundler_groups, "").to_s.split(',').map(&:strip)
      version = options[:version] || "0.0.0"
      homepage = options[:homepage]

      gem_dir = File.join(projects_path, gem_name)

      FileUtils.mkdir(gem_dir)
      File.open(File.join(gem_dir, "#{gem_name}.gemspec"), 'w') do |file|
        file.write <<-GEMSPEC
          Gem::Specification.new do |s|
            s.name = "#{gem_name}"
            s.version = "#{version}"
            s.author = "Cucumber"
            s.summary = "#{summary}"
            s.license = "#{license}"
            s.description = "#{description}"
            s.homepage = "#{homepage}"
          end
        GEMSPEC
      end

      gem_options = {}
      gem_options[:path] = File.join(projects_path, gem_name)
      gem_options[:groups] = bundler_groups unless bundler_groups.empty?

      add_gem_dependency(gem_name, gem_options)

      bundle_app
    end

    def configure_license_finder_whitelist(whitelisted_licenses=[])
      FileUtils.mkdir_p(config_path)
      File.open(File.join(config_path, "license_finder.yml"), "w") do |f|
        f.write({'whitelist' => whitelisted_licenses}.to_yaml)
      end
    end

    def configure_license_finder_bundler_whitelist(whitelisted_groups=[])
      whitelisted_groups = Array whitelisted_groups
      FileUtils.mkdir_p(config_path)
      File.open(File.join(config_path, "license_finder.yml"), "w") do |f|
        f.write({'ignore_groups' => whitelisted_groups}.to_yaml)
      end
    end

    def execute_command(command)
      Bundler.with_clean_env do
        @output = `cd #{app_path} && bundle exec #{command}`
      end

      @output
    end

    def app_path(sub_directory = nil)
      path = app_path = Pathname.new(File.join(projects_path, app_name)).cleanpath.to_s

      if sub_directory
        path = Pathname.new(File.join(app_path, sub_directory)).cleanpath.to_s

        raise "#{name} is outside of the app" unless path =~ %r{^#{app_path}/}
      end

      path
    end

    def config_path
      File.join(app_path, 'config')
    end

    def doc_path
      File.join(app_path, 'doc')
    end

    def dependencies_file_path
      File.join(doc_path, 'dependencies.yml')
    end

    def dependencies_html_path
      File.join(doc_path, 'dependencies.html')
    end

    def add_gem_dependency(name, options = {})
      line = "gem #{name.inspect}"
      line << ", " + options.inspect unless options.empty?

      add_to_gemfile(line)
    end

    def bundle_app
      Bundler.with_clean_env do
        `bundle install --gemfile=#{File.join(app_path, "Gemfile")} --path=#{bundle_path}`
      end
    end

    def modifying_dependencies_file
      FileUtils.mkdir_p(File.dirname(dependencies_file_path))
      File.open(dependencies_file_path, 'w+') { |f| yield f }
    end

    private

    def add_to_gemfile(line)
      `echo #{line.inspect} >> #{File.join(app_path, "Gemfile")}`
    end

    def add_to_rakefile(line)
      `echo #{line.inspect} >> #{File.join(app_path, "Rakefile")}`
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

    def root_path
      Pathname.new(File.join(File.dirname(__FILE__), "..", "..")).realpath.to_s
    end
  end
end
