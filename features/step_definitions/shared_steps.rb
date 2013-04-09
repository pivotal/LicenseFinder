require 'fileutils'
require 'pathname'
require 'bundler'
require 'capybara'

########## COMMON STEPS ##########

When(/^I run license_finder$/) do
  @output = @user.execute_command "license_finder -q"
end

When(/^I whitelist MIT and 'other' licenses$/) do
  @user.configure_license_finder_whitelist ["MIT","other"]
  @output = @user.execute_command "license_finder -q"
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
