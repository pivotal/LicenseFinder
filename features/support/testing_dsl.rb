require 'bundler'
require 'delegate'
require 'forwardable'

module LicenseFinder::TestingDSL
  class User
    def run_license_finder
      execute_command "license_finder --quiet"
    end

    def create_empty_project
      EmptyProject.create
    end

    def create_ruby_app
      RubyProject.create
    end

    def execute_command(command)
      ::Bundler.with_clean_env do
        @output, @last_command_exit_status = Paths.project.shell_out("bundle exec #{command}", true)
      end
    end

    def seeing?(content)
      @output.include? content
    end

    def seeing_line?(content)
      seeing_something_like? /^#{Regexp.escape content}$/
    end

    def seeing_something_like?(regex)
      @output =~ regex
    end

    def receiving_exit_code?(code)
      @last_command_exit_status.exitstatus == code
    end

    def view_html
      HtmlReport.new(@output)
    end
  end

  module Shell
    def self.run(command, allow_failures = false)
      output = `#{command} 2>&1`
      status = $?
      unless status.success? || allow_failures
        message_format = <<EOM
Command failed: `%s`
output: %s
exit: %d
EOM
        message = sprintf message_format, command, output.chomp, status.exitstatus
        raise RuntimeError.new(message)
      end

      return [output, status]
    end
  end

  class ProjectDir < SimpleDelegator
    def shell_out(command, allow_failures = false)
      Shell.run("cd #{self} && #{command} 2>&1", allow_failures)
    end

    def add_to_file(filename, line)
      shell_out("echo #{line.inspect} >> #{join(filename)}")
    end

    def install_fixture(fixture_name)
      join(fixture_name).make_symlink Paths.fixtures.join(fixture_name)
    end

    def make
      mkpath
    end
  end

  require 'pathname'
  module Paths
    extend self

    def project
      ProjectDir.new(projects.join("my_app").cleanpath)
    end

    def projects
      root.join("tmp").join("projects")
    end

    def root
      Pathname.new(__FILE__).dirname.join("..", "..").realpath
    end

    def reset_projects!
      projects.rmtree
      projects.mkpath
    end

    def fixtures
      root.join("spec", "fixtures")
    end
  end

  class Project
    extend Forwardable
    def_delegators :project_dir, :shell_out, :add_to_file, :install_fixture

    def self.create
      project = new
      project.add_dep
      project.install
      project
    end

    def initialize
      Paths.reset_projects!
      project_dir.make
    end

    def add_dep
    end

    def install
    end

    private

    def project_dir
      Paths.project
    end
  end

  class EmptyProject < Project
  end

  class PythonProject < Project
    def add_dep
      add_to_file("requirements.txt", 'argparse==1.2.1')
    end

    def install
      shell_out("pip install -r requirements.txt")
    end
  end

  class NodeProject < Project
    def add_dep
      add_to_file("package.json", '{"dependencies" : {"http-server": "0.6.1"}}')
    end

    def install
      shell_out("npm install 2>/dev/null")
    end
  end

  class BowerProject < Project
    def add_dep
      add_to_file('bower.json', '{"name": "my_app", "dependencies" : {"gmaps": "0.2.30"}}')
    end

    def install
      shell_out("bower install 2>/dev/null")
    end
  end

  class MavenProject < Project
    def add_dep
      install_fixture("pom.xml")
    end

    def install
      shell_out("mvn install")
    end
  end

  class GradleProject < Project
    def add_dep
      install_fixture("build.gradle")
    end
  end

  class CocoaPodsProject < Project
    def add_dep
      install_fixture("Podfile")
    end

    def install
      shell_out("pod install --no-integrate")
    end
  end

  class RubyProject < Project
    def initialize
      Paths.reset_projects!
      Shell.run("cd #{Paths.projects} && bundle gem my_app")
    end

    def add_dep
      add_to_bundler('license_finder', path: Paths.root.to_s)
    end

    def install
      ::Bundler.with_clean_env do
        shell_out("bundle check || bundle install")
      end
    end

    def create_and_depend_on(gem_name, gem_spec_options = {}, bundler_options = {})
      create_gem(gem_name, gem_spec_options)
      depend_on_local_gem(gem_name, bundler_options)
    end

    private

    def create_gem(gem_name, options)
      # TODO: should a local gem be a Project?
      gem_dir = Paths.projects.join(gem_name)
      gem_dir.mkpath

      gem_dir.join("#{gem_name}.gemspec").open('w') do |file|
        file.write gemspec_string(gem_name, options)
      end
    end

    def depend_on_local_gem(gem_name, options)
      gem_dir = Paths.projects.join(gem_name)
      options[:path] = gem_dir.to_s

      add_to_bundler(gem_name, options)

      install
    end

    def gemspec_string(gem_name, options)
      if options.has_key?(:license) && options.has_key?(:licenses)
        raise "Can't specify both `license` and `licenses`"
      end

      license_key = ([:license, :licenses] & options.keys).first
      license_value = options.fetch(license_key)
      summary = options.fetch(:summary, "")
      description = options.fetch(:description, "")
      version = options[:version] || "0.0.0"
      homepage = options[:homepage]

      <<-GEMSPEC
      Gem::Specification.new do |s|
        s.name = "#{gem_name}"
        s.version = "#{version}"
        s.author = "Cucumber"
        s.summary = "#{summary}"
        s.#{license_key} = #{license_value.inspect}
        s.description = "#{description}"
        s.homepage = "#{homepage}"
      end
      GEMSPEC
    end

    def add_to_bundler(name, options)
      line = "gem #{name.inspect}, #{options.inspect}"

      add_to_file("Gemfile", line)
    end
  end

  require 'capybara'
  class HtmlReport < SimpleDelegator
    def initialize(str)
      super(Capybara.string(str))
    end

    def in_dep(dep_name)
      result = find("##{dep_name}")
      yield result if block_given?
      result
    end

    def approved?(dep_name)
      classes_of(dep_name).include? "approved"
    end

    def unapproved?(dep_name)
      classes_of(dep_name).include? "unapproved"
    end

    def has_title?(title)
      find("h1").has_content? title
    end

    private

    def classes_of(dep_name)
      in_dep(dep_name)[:class].split(' ')
    end
  end
end
