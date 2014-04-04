require 'fileutils'
require 'pathname'
require 'bundler'
require 'capybara'

########## COMMON STEPS ##########

Given(/^I have an app with license finder$/) do
  @user = ::DSL::User.new
  @user.create_nonrails_app
end

When(/^I run license_finder$/) do
  @output = @user.execute_command "license_finder --quiet"
end

When(/^I whitelist MIT, New BSD, Apache 2.0, Ruby, and other licenses$/) do
  @user.configure_license_finder_whitelist ["MIT","other","New BSD","Apache 2.0","Ruby"]
  @output = @user.execute_command "license_finder --quiet"
end

Then(/^I should see the project name (\w+) in the html$/) do |project_name|
  html = File.read(@user.dependencies_html_path)
  page = Capybara.string(html)
  title = page.find("h1")

  title.should have_content project_name
end


module DSL
  class User
    def create_python_app
      reset_projects!

      shell_out("mkdir -p #{app_path}")
      shell_out("cd #{app_path} && touch requirements.txt")

      add_pip_dependency('argparse==1.2.1')

      pip_install
    end

    def create_node_app
      reset_projects!

      shell_out("mkdir -p #{app_path}")
      shell_out("cd #{app_path} && touch package.json")

      add_npm_dependency('http-server', '0.6.1')

      npm_install
    end

    def create_maven_app
      reset_projects!

      path = File.expand_path("spec/fixtures/pom.xml")

      shell_out("mkdir -p #{app_path}")
      shell_out("cd #{app_path} && cp #{path} .")

      mvn_install
    end

    def create_gradle_app
      reset_projects!

      path = File.expand_path("spec/fixtures/build.gradle")

      shell_out("mkdir -p #{app_path}")
      shell_out("cd #{app_path} && cp #{path} .")
    end

    def create_nonrails_app
      reset_projects!

      shell_out("cd #{projects_path} && bundle gem #{app_name}")

      add_gem_dependency('license_finder', :path => root_path)

      bundle_app
    end

    def create_rails_app
      reset_projects!

      shell_out("bundle exec rails new #{app_path} --skip-bundle")

      add_gem_dependency('license_finder', :path => root_path)

      bundle_app
    end

    def create_cocoapods_app
      reset_projects!

      path = File.expand_path("spec/fixtures/Podfile")

      shell_out("mkdir -p #{app_path}")
      shell_out("cp #{path} #{app_path}")

      shell_out("cd #{app_path} && pod install --no-integrate")
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

    def execute_command(command)
      ::Bundler.with_clean_env do
        @output = shell_out("cd #{app_path} && bundle exec #{command}", true)
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

    def dependencies_html_path
      File.join(doc_path, 'dependencies.html')
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
        shell_out("bundle install --gemfile=#{File.join(app_path, "Gemfile")} --path=#{bundle_path}")
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

    private

    def add_to_gemfile(line)
      shell_out("echo #{line.inspect} >> #{File.join(app_path, "Gemfile")}")
    end

    def add_to_requirements(line)
      shell_out("echo #{line.inspect} >> #{File.join(app_path, "requirements.txt")}")
    end

    def add_to_package(line)
      shell_out("echo #{line.inspect} >> #{File.join(app_path, "package.json")}")
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
      shell_out("rm -rf #{projects_path}")
      shell_out("mkdir -p #{projects_path}")
    end

    def root_path
      Pathname.new(File.join(File.dirname(__FILE__), "..", "..")).realpath.to_s
    end

    def shell_out(command, allow_failures = false)
      output = `#{command}`
      raise RuntimeError.new("command failed #{command}") if !$?.success? && !allow_failures
      output
    end
  end
end
