require 'delegate'

module LicenseFinder::TestingDSL
  class User
    def run_license_finder
      execute_command "license_finder --quiet"
    end

    def create_empty_project
      EmptyProject.create
    end

    def create_ruby_app
      BundlerProject.create
    end

    def create_gem(name, options)
      GemProject.create(name, options)
    end

    def execute_command(command)
      @output, @exit_code = Paths.project.shell_out(command, true)
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
      @exit_code == code
    end

    def view_html
      execute_command 'license_finder report --format html'
      HtmlReport.from_string(@output)
    end
  end

  require 'forwardable'
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

  class PipProject < Project
    def add_dep
      add_to_file("requirements.txt", 'argparse==1.2.1')
    end

    def install
      shell_out("pip install -r requirements.txt")
    end
  end

  class NpmProject < Project
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
  
  class RebarProject < Project
    def add_dep
      install_fixture("rebar.config")
    end

    def install
      shell_out("rebar get-deps")
    end
  end

  class BundlerProject < Project
    def add_dep
      add_to_bundler('license_finder', path: Paths.root.to_s)
    end

    def install
      shell_out("bundle install")
    end

    def depend_on(gem, bundler_options = {})
      add_to_bundler(gem.name, bundler_options.merge(path: gem.project_dir.to_s))
      install
    end

    private

    def add_to_bundler(gem_name, options)
      add_to_file("Gemfile", "gem #{gem_name.inspect}, #{options.inspect}")
    end
  end

  class GemProject # lives adjacent to a BundlerProject, so has a different lifecycle from other Projects and doesn't inherit
    def self.create(name, options)
      result = new(name)
      result.define(options)
      result
    end

    def initialize(name)
      @name = name
      project_dir.make
    end

    def define(options)
      project_dir.write_file("#{name}.gemspec", gemspec_string(options))
    end

    attr_reader :name

    def project_dir
      Paths.project(name)
    end

    private

    def gemspec_string(options)
      <<-GEMSPEC
      Gem::Specification.new do |s|
        s.name = "#{name}"
        s.version = "#{options[:version] || "0.0.0"}"
        s.license = "#{options.fetch(:license)}"
        s.author = "license_finder tests"
        s.summary = "#{options[:summary]}"
        s.description = "#{options[:description]}"
        s.homepage = "#{options[:homepage]}"
      end
      GEMSPEC
    end
  end

  require 'capybara'
  class HtmlReport < SimpleDelegator # delegates to the parsed html
    def self.from_string(str)
      new(Capybara.string(str))
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

    def titled?(title)
      find("h1").has_content? title
    end

    private

    def classes_of(dep_name)
      in_dep(dep_name)[:class].split(' ')
    end
  end

  class ProjectDir < SimpleDelegator # delegates to a Pathname
    def shell_out(command, allow_failures = false)
      Shell.run("cd #{self} && #{command}", allow_failures)
    end

    def add_to_file(filename, content)
      join(filename).open('a') { |file| file.puts content }
    end

    def write_file(filename, content)
      join(filename).open('w') { |file| file.write content }
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

    def root
      # where license_finder is installed
      Pathname.new(__FILE__).dirname.join("..", "..").realpath
    end

    def fixtures
      root.join("features", "fixtures")
    end

    def projects
      root.join("tmp", "projects")
    end

    def project(name = "my_app")
      ProjectDir.new(projects.join(name))
    end

    def reset_projects!
      # only destroyed when a test starts, so you can poke around after a failure
      projects.rmtree if projects.exist?
      projects.mkpath
    end
  end

  module Shell
    ERROR_MESSAGE_FORMAT = <<EOM
Command failed: `%s`
output: %s
exit: %d
EOM

    def self.run(command, allow_failures = false)
      output = `#{command} 2>&1`
      status = $?
      unless status.success? || allow_failures
        message = sprintf ERROR_MESSAGE_FORMAT, command, output.chomp, status.exitstatus
        raise RuntimeError.new(message)
      end

      return [output, status.exitstatus]
    end
  end
end
