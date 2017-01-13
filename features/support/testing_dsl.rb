require 'delegate'

module LicenseFinder
  module TestingDSL
    class User
      def run_license_finder(path = nil, options='')
        if path
          execute_command_in_path("license_finder --quiet #{options}", Paths.project("my_app/#{path}"))
        else
          execute_command "license_finder --quiet #{options}"
        end
      end

      def create_empty_project(name = "my_app")
        EmptyProject.create(name)
      end

      def create_ruby_app(name = "my_app")
        BundlerProject.create(name)
      end

      def create_gem(name, options)
        GemProject.create(name, options)
      end

      def create_gem_in_path(name, path, options)
        GemProject.create_in_path(name, path, options)
      end

      def execute_command(command)
        execute_command_in_path(command, Paths.project)
      end

      def execute_command_outside_project(command)
        execute_command_in_path(command, Paths.root)
      end

      def seeing?(content)
        @output.include? content
      end

      def seeing_once?(content)
        @output.scan(/#{Regexp.escape content}/).size == 1
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

      private

      def execute_command_in_path(command, path)
        @output, @exit_code = path.shell_out(command, true)
      end
    end

    require 'forwardable'
    class Project
      extend Forwardable
      def_delegators :project_dir, :shell_out, :add_to_file, :install_fixture

      attr_reader :name

      def self.create(name = "my_app")
        project = new(name)
        project.add_dep
        project.install
        project
      end

      def initialize(name = "my_app")
        @name = name
        project_dir.make
      end

      def add_dep
      end

      def install
      end

      def project_dir
        Paths.project(name)
      end

      def clone(fixture_name)
        FileUtils.mkpath(Paths.my_app.join(fixture_name))
        FileUtils.cp_r(Paths.fixtures.join(fixture_name), Paths.my_app)
      end
    end

    class EmptyProject < Project
    end

    class PipProject < Project
      def add_dep
        add_to_file("requirements.txt", 'rsa==3.1.4')
      end

      def install
        shell_out("pip install -r requirements.txt --user")
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
        shell_out("bower install --allow-root 2>/dev/null")
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

    class BareGradleProject < Project
      def add_dep
        install_fixture('build.gradle')
      end
    end

    class GradleProject < Project
      def add_dep
        clone('single-module-gradle')
      end

      class MultiModule < Project
        def add_dep
          clone('multi-module-gradle')
        end
      end

      class FileBasedLibs < Project
        def add_dep
          clone('file-based-libs-gradle')
        end
      end
    end

    class AlternateBuildFileGradleProject < Project
      def add_dep
        clone('alternate-build-file-gradle')
      end
    end

    class GoProject < Project
      def add_dep
        clone('gopath')
      end

      def install
        shell_out("GOPATH=#{project_dir}/gopath godep restore")
      end

      def shell_out(command)
        ProjectDir.new(Paths.root.join('tmp', 'projects', 'my_app', 'gopath', 'src', 'github.com', 'pivotal', 'foo')).shell_out(command)
      end
    end

    class CompositeProject < Project
      def add_dep
        clone('single-module-gradle')
        clone('multi-module-gradle')
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

    class NugetProject < Project
      def add_dep
        clone('nuget')
      end
    end

    class BundlerProject < Project
      def add_dep
        add_to_gemfile("source 'https://rubygems.org'")
        add_gem_to_gemfile('license_finder', path: Paths.root.to_s)
      end

      def install
        shell_out("bundle install")
      end

      def depend_on(gem, bundler_options = {})
        add_gem_to_gemfile(gem.name, bundler_options.merge(path: gem.project_dir.to_s))
        install
      end

      private

      def add_gem_to_gemfile(gem_name, options)
        add_to_gemfile("gem #{gem_name.inspect}, #{options.inspect}")
      end

      def add_to_gemfile(content)
        add_to_file("Gemfile", content)
      end
    end

    class GemProject # lives adjacent to a BundlerProject, so has a different lifecycle from other Projects and doesn't inherit
      def self.create(name, options)
        result = new(name)
        result.define(options)
        result
      end

      def self.create_in_path(name, path, options)
        result = new(name, path)
        result.define(options)
        result
      end

      def initialize(name, path = nil)
        @name = name
        @path = path
        project_dir.make
      end

      def define(options)
        project_dir.write_file("#{name}.gemspec", gemspec_string(options))
      end

      attr_reader :name, :path

      def project_dir
        if path
          Paths.project(path + '/' + name)
        else
          Paths.project(name)
        end
      end

      private

      def gemspec_string(options)
        dependencies = Array(options[:dependencies]).map do |dep|
          %[s.add_dependency "#{dep}"]
        end.join("\n")

        <<-GEMSPEC
      Gem::Specification.new do |s|
        s.name = "#{name}"
        s.version = "#{options[:version] || "0.0.0"}"
        s.license = "#{options.fetch(:license)}"
        s.author = "license_finder tests"
        s.summary = "#{options[:summary]}"
        s.description = "#{options[:description]}"
        s.homepage = "#{options[:homepage]}"
        #{dependencies}
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
        Dir.chdir(self) { Shell.run(command, allow_failures) }
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
        ProjectDir.new(Pathname.new(__FILE__).dirname.join("..", "..").realpath)
      end

      def fixtures
        root.join("features", "fixtures")
      end

      def projects
        root.join("tmp", "projects")
      end

      def my_app
        root.join("tmp", "projects", "my_app")
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
end
