require 'fileutils'
require 'pathname'
require 'bundler'
require 'capybara'

module LicenseFinder::TestingDSL
  module Shell
    def shell_out(command, allow_failures = false)
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

      @last_command_exit_status = status
      output
    end
  end

  module Paths
    include Shell
    extend self

    def app
      projects.join("my_app").cleanpath
    end

    def projects
      root.join("tmp").join("projects")
    end

    def fixtures
      root.join("spec", "fixtures")
    end

    def root
      Pathname.new(__FILE__).dirname.join("..", "..").realpath
    end

    def add_to_file(filename, line)
      shell_out("echo #{line.inspect} >> #{app.join(filename)}")
    end

    def reset_projects!
      shell_out("rm -rf #{projects}")
      projects.mkpath
    end

    def create_empty_project
      reset_projects!
      app.mkpath
    end
  end

  class Project
    include Shell

    def self.create
      project = new
      project.activate
      project.add_dep
      project.install
      project
    end

    def initialize
      Paths.create_empty_project
    end

    def activate
    end

    def add_dep
    end

    def install
    end
  end

  class EmptyProject < Project
  end

  class PythonProject < Project
    def activate
      shell_out("cd #{Paths.app} && touch requirements.txt")
    end

    def add_dep
      Paths.add_to_file("requirements.txt", 'argparse==1.2.1')
    end

    def install
      shell_out("cd #{Paths.app} && pip install -r requirements.txt")
    end
  end

  class NodeProject < Project
    def activate
      shell_out("cd #{Paths.app} && touch package.json")
    end

    def add_dep
      line = "{\"dependencies\" : {\"http-server\": \"0.6.1\"}}"
      Paths.add_to_file("package.json", line)
    end

    def install
      shell_out("cd #{Paths.app} && npm install 2>/dev/null")
    end
  end

  class BowerProject < Project
    def activate
      shell_out("cd #{Paths.app} && touch bower.json")
    end

    def add_dep
      line = "{\"name\": \"my_app\", \"dependencies\" : {\"gmaps\": \"0.2.30\"}}"
      Paths.add_to_file('bower.json', line)
    end

    def install
      shell_out("cd #{Paths.app} && bower install 2>/dev/null")
    end
  end

  class MavenProject < Project
    def add_dep
      path = Paths.fixtures.join("pom.xml")
      shell_out("cp #{path} #{Paths.app}")
    end

    def install
      shell_out("cd #{Paths.app} && mvn install")
    end
  end

  class GradleProject < Project
    def add_dep
      path = Paths.fixtures.join("build.gradle")
      shell_out("cd #{Paths.app} && cp #{path} .")
    end
  end

  class CocoaPodsProject < Project
    def add_dep
      path = Paths.fixtures.join("Podfile")
      shell_out("cp #{path} #{Paths.app}")
    end

    def install
      shell_out("cd #{Paths.app} && pod install --no-integrate")
    end
  end

  class RubyProject < Project
    def initialize
      Paths.reset_projects!
    end

    def activate
      shell_out("cd #{Paths.projects} && bundle gem my_app")
    end

    def add_dep
      add_to_bundler('license_finder', path: Paths.root.to_s)
    end

    def install
      ::Bundler.with_clean_env do
        shell_out("cd #{Paths.app} && bundle check || bundle install")
      end
    end

    def create_and_depend_on(gem_name, gem_spec_options = {}, bundler_options = {})
      create_gem(gem_name, gem_spec_options)
      depend_on_local_gem(gem_name, bundler_options)
    end

    private

    def create_gem(gem_name, options)
      gem_dir = Paths.projects.join(gem_name)

      gem_dir.mkpath
      gem_dir.join("#{gem_name}.gemspec").open('w') do |file|
        file.write gemspec_string(gem_name, options)
      end
    end

    def depend_on_local_gem(gem_name, options={})
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

    def add_to_bundler(name, options = {})
      line = "gem #{name.inspect}, #{options.inspect}"

      Paths.add_to_file("Gemfile", line)
    end
  end


  class User
    include Shell

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
        @output = shell_out("cd #{Paths.app} && bundle exec #{command}", true)
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

    def in_html
      yield Capybara.string(@output)
    end

    def in_dep_html(dep_name)
      in_html do |page|
        yield page.find("##{dep_name}")
      end
    end

    def html_formatting_of(dep_name)
      in_dep_html(dep_name) do |dep|
        dep[:class].split(' ')
      end
    end

    def html_title
      in_html { |page| page.find("h1") }
    end
  end
end
