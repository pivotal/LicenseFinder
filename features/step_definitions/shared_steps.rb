require 'fileutils'
require 'pathname'
require 'bundler'
require 'capybara'

########## COMMON STEPS ##########

Given(/^I have an app with license finder$/) do
  @user = ::DSL::User.new
  @user.create_ruby_app
end

When(/^I run license_finder$/) do
  @output = @user.execute_command "license_finder --quiet"
end

When(/^I whitelist MIT, New BSD, Apache 2.0, Ruby, and other licenses$/) do
  @user.configure_license_finder_whitelist ["MIT","other","New BSD","Apache 2.0","Ruby"]
  @output = @user.execute_command "license_finder --quiet"
end

Then(/^I should see the project name (\w+) in the html$/) do |project_name|
  @user.in_html do |page|
    title = page.find("h1")

    title.should have_content project_name
  end
end


module DSL
  class User
    def create_python_app
      reset_projects!

      app_path.mkpath
      shell_out("cd #{app_path} && touch requirements.txt")

      add_pip_dependency('argparse==1.2.1')

      pip_install
    end

    def create_node_app
      reset_projects!

      app_path.mkpath
      shell_out("cd #{app_path} && touch package.json")

      add_npm_dependency('http-server', '0.6.1')

      npm_install
    end

    def create_maven_app
      reset_projects!

      path = fixtures_path.join("pom.xml")

      app_path.mkpath
      shell_out("cp #{path} #{app_path}")

      mvn_install
    end

    def create_gradle_app
      reset_projects!

      path = fixtures_path.join("build.gradle")

      app_path.mkpath
      shell_out("cd #{app_path} && cp #{path} .")
    end

    def create_ruby_app
      reset_projects!

      shell_out("cd #{projects_path} && bundle gem #{app_name}")

      add_gem_dependency('license_finder', :path => root_path.to_s)

      bundle_app
    end

    def create_cocoapods_app
      reset_projects!

      path = fixtures_path.join("Podfile")

      app_path.mkpath
      shell_out("cp #{path} #{app_path}")
      shell_out("cd #{app_path} && pod install --no-integrate")
    end

    def create_and_depend_on_gem(gem_name, options)
      create_gem(gem_name, options)
      depend_on_gem(gem_name)
    end

    def create_gem(gem_name, options)
      license = options.fetch(:license)
      summary = options.fetch(:summary, "")
      description = options.fetch(:description, "")
      version = options[:version] || "0.0.0"
      homepage = options[:homepage]

      gem_dir = projects_path.join(gem_name)

      gem_dir.mkpath
      gem_dir.join("#{gem_name}.gemspec").open('w') do |file|
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
    end

    def depend_on_gem(gem_name, options={})
      gem_dir = projects_path.join(gem_name)

      gem_options = {}
      gem_options[:path] = gem_dir.to_s
      gem_options[:groups] = [options[:bundler_group]] if options[:bundler_group]

      add_gem_dependency(gem_name, gem_options)

      bundle_app
    end

    def configure_license_finder_whitelist(whitelisted_licenses=[])
      config_path.mkpath
      config_file.open("w") do |f|
        f.write({'whitelist' => whitelisted_licenses}.to_yaml)
      end
    end

    def execute_command(command)
      ::Bundler.with_clean_env do
        @output = shell_out("cd #{app_path} && bundle exec #{command}", true)
      end

      @output
    end

    def app_path(sub_directory = nil)
      path = base_path = projects_path.join(app_name).cleanpath

      if sub_directory
        path = base_path.join(sub_directory).cleanpath

        raise "#{sub_directory} is outside of the app" unless path.to_s =~ %r{^#{base_path}/}
      end

      path
    end

    def config_path
      app_path('config')
    end

    def config_file
      config_path.join("license_finder.yml")
    end

    def add_gem_dependency(name, options = {})
      line = "gem #{name.inspect}"
      line << ", " + options.inspect unless options.empty?

      add_to_gemfile(line)
    end

    def add_pip_dependency(dependency)
      add_to_requirements(dependency)
    end

    def add_npm_dependency(dependency, version)
      line = "{\"dependencies\" : {\"#{dependency}\": \"#{version}\"}}"

      add_to_package(line)
    end

    def bundle_app
      ::Bundler.with_clean_env do
        shell_out("bundle install --gemfile=#{app_path.join("Gemfile")} --path=#{sandbox_path.join("bundle")}")
      end
    end

    def pip_install
      shell_out("cd #{app_path} && pip install -r requirements.txt")
    end

    def npm_install
      shell_out("cd #{app_path} && npm install 2>/dev/null")
    end

    def mvn_install
      shell_out("cd #{app_path} && mvn install")
    end

    def in_html
      yield Capybara.string(dependencies_html_path.read)
    end

    private

    def add_to_gemfile(line)
      shell_out("echo #{line.inspect} >> #{app_path.join("Gemfile")}")
    end

    def add_to_requirements(line)
      shell_out("echo #{line.inspect} >> #{app_path.join("requirements.txt")}")
    end

    def add_to_package(line)
      shell_out("echo #{line.inspect} >> #{app_path.join("package.json")}")
    end

    def app_name
      "my_app"
    end

    def sandbox_path
      root_path.join("tmp")
    end

    def projects_path
      sandbox_path.join("projects")
    end

    def fixtures_path
      root_path.join("spec", "fixtures")
    end

    def dependencies_html_path
      app_path.join('doc', 'dependencies.html')
    end

    def reset_projects!
      shell_out("rm -rf #{projects_path}")
      projects_path.mkpath
    end

    def root_path
      Pathname.new(__FILE__).dirname.join("..", "..").realpath
    end

    def shell_out(command, allow_failures = false)
      output = `#{command}`
      raise RuntimeError.new("command failed #{command}") if !$?.success? && !allow_failures
      output
    end
  end
end
