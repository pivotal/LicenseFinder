# frozen_string_literal: true

require 'delegate'
require 'English'
require 'json'

module LicenseFinder
  module TestingDSL
    class User
      def run_license_finder(path = nil, options = '')
        if path
          execute_command_in_path("license_finder --quiet #{options}", Paths.project("my_app/#{path}"))
        else
          execute_command "license_finder --quiet #{options}"
        end
      end

      def create_empty_project(name = 'my_app')
        EmptyProject.create(name)
      end

      def create_ruby_app(name = 'my_app')
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
        execute_command_in_path(command, Paths.tmpdir)
      end

      def seeing?(content)
        @output.include? content
      end

      def seeing_once?(content)
        @output.scan(/#{Regexp.escape content}/).size == 1
      end

      def seeing_line?(content)
        seeing_something_like?(/^#{Regexp.escape content}$/)
      end

      def seeing_something_like?(regex)
        !!(@output =~ regex)
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
      def_delegators :project_dir, :shell_out, :add_to_file, :remove_lines_with_value, :install_fixture

      attr_reader :name

      def self.create(name = 'my_app')
        project = new(name)
        project.add_dep
        project.install
        project
      end

      def initialize(name = 'my_app')
        @name = name
        project_dir.make
      end

      def add_dep; end

      def install; end

      def project_dir
        Paths.project(name)
      end

      def clone_go_project(fixture_name)
        FileUtils.mkpath(Paths.project.join('src', fixture_name))
        FileUtils.cp_r(Paths.fixtures.join(fixture_name), Paths.project.join('src'))
      end

      def clone(fixture_name)
        FileUtils.mkpath(Paths.project.join(fixture_name))
        FileUtils.cp_r(Paths.fixtures.join(fixture_name), Paths.project)
      end
    end

    class EmptyProject < Project
    end

    class CondaProject < Project
      attr_reader :env

      def initialize(name = 'my_app')
        @env = name
        super
        add_to_file('environment.yml', "name: #{@env}")
        add_channels
        add_to_file('environment.yml', 'dependencies:')
      end

      def conda_root
        @conda_root ||= "#{ENV['HOME']}/miniconda3"
      end

      def add_channels(*list_of_channels)
        list_of_channels = %w[defaults conda-forge] if list_of_channels.empty?
        add_to_file('environment.yml', "channels: [#{list_of_channels.join(',')}]")
      end

      def add_dep
        add_to_file('environment.yml', '- zlib=1.2.11')
      end

      def install
        shell_out("bash -c 'source #{conda_root}/etc/profile.d/conda.sh && conda env create -f environment.yml'") unless
          Dir.exist?("#{conda_root}/envs/#{env}")
      end
    end

    class PipProject < Project
      def add_dep
        add_to_file('requirements.txt', 'rsa==3.1.4')
      end

      def add_dep_with_platform(platform)
        add_to_file('requirements.txt', "colorama==0.3.9;platform_system==\"#{platform}\"")
      end

      def install
        shell_out('pip install -r requirements.txt --user')
      end
    end

    class PipenvProject < Project
      def add_dep
        content = ::JSON.pretty_generate(
          "_meta": {
            "hash": { "sha256": '' },
            "pipfile-spec": 6,
            "requires": { "python_version": '3.8' },
            "sources": [{ "name": 'pypi', "url": 'https://pypi.org/simple', "verify_ssl": true }]
          },
          "default": { "six": { "hashes": ['', ''], "index": 'pypi', "version": '==1.13.0' } },
          "develop": {}
        )
        add_to_file('Pipfile.lock', content)
      end

      def install
        shell_out('ls')
      end
    end

    class NpmProject < Project
      def add_dep
        add_to_file('package.json', '{"dependencies" : {"http-server": "0.11.1"}}')
      end

      def install
        shell_out('npm install 2>/dev/null')
      end
    end

    class NpmProjectWithInvalidDependency < Project
      def add_dep
        add_to_file('package.json', '{"dependencies" : {"gertie-watch": "0.11.1"}}')
      end

      def install
        # no install since this should crash.
      end
    end

    class BowerProject < Project
      def add_dep
        add_to_file('bower.json', '{"name": "my_app", "dependencies" : {"gmaps": "0.2.30"}}')
      end

      def install
        shell_out('bower install --allow-root 2>/dev/null')
      end
    end

    class ComposerProject < Project
      def add_dep
        install_fixture('composer.json')
      end

      def install
        shell_out('composer install')
      end
    end

    class YarnProject < Project
      def add_dep
        add_to_file('yarn.lock', '')
        add_to_file('package.json', '{"dependencies" : {"http-server": "0.11.1"}}')
      end
    end

    class MavenProject < Project
      def add_dep
        install_fixture('pom.xml')
      end

      def install
        shell_out('mvn install')
      end
    end

    class SbtProject < Project
      def add_dep
        install_fixture('sbt')
      end

      def install
        shell_out('sbt update')
      rescue RuntimeError
        shell_out('sbt update')
      end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('sbt')).shell_out(command)
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

    class KtsBuildFileGradleProject < Project
      def add_dep
        clone('kts-build-file-gradle')
      end
    end

    class GoProject < Project
      def add_dep
        clone('gopath')
      end

      def install
        orig_gopath = ENV['GOPATH']
        ENV['GOPATH'] = "#{project_dir}/gopath"
        shell_out('godep restore')
        ENV['GOPATH'] = orig_gopath
      end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('gopath', 'src', 'github.com', 'pivotal', 'foo')).shell_out(command)
      end
    end

    class GoModulesProject < Project
      def add_dep
        clone('go_modules')
      end

      def install
        shell_out('go mod vendor')
      end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('go_modules')).shell_out(command)
      end
    end

    class GlideProject < Project
      def add_dep
        clone_go_project('gopath_glide')
      end

      def install
        orig_gopath = ENV['GOPATH']
        ENV['GOPATH'] = project_dir.to_s
        shell_out('glide install')
        ENV['GOPATH'] = orig_gopath
      end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('src', 'gopath_glide', 'src')).shell_out(command)
      end
    end

    class GlideProjectWithoutSrc < Project
      def add_dep
        clone_go_project('gopath_glide_without_src')
      end

      def install
        orig_gopath = ENV['GOPATH']
        ENV['GOPATH'] = project_dir.to_s
        shell_out('glide install')
        ENV['GOPATH'] = orig_gopath
      end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('src', 'gopath_glide_without_src')).shell_out(command)
      end
    end

    class GlideProjectWithRootAndSrc < Project
      def add_dep
        clone_go_project('gopath_glide_in_root_and_src')
      end

      def install
        orig_gopath = ENV['GOPATH']
        ENV['GOPATH'] = project_dir.to_s
        shell_out_root('glide install')
        shell_out_src('glide install')
        ENV['GOPATH'] = orig_gopath
      end

      def shell_out_root(command)
        ProjectDir.new(Paths.project.join('src', 'gopath_glide_in_root_and_src')).shell_out(command)
      end

      def shell_out_src(command)
        ProjectDir.new(Paths.project.join('src', 'gopath_glide_in_root_and_src', 'src')).shell_out(command)
      end
    end

    class TrashProject < Project
      def add_dep
        clone('gopath_trash')
      end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('gopath_trash')).shell_out(command)
      end
    end

    class PreparedTrashProject < Project
      def add_dep
        clone('gopath_trash_prepared')
      end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('gopath_trash_prepared')).shell_out(command)
      end
    end

    class GvtProject < Project
      def add_dep
        clone('gopath_gvt')
      end

      def install
        orig_gopath = ENV['GOPATH']
        ENV['GOPATH'] = "#{project_dir}/gopath_gvt"
        shell_out('gvt restore')
        ENV['GOPATH'] = orig_gopath
      end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('gopath_gvt', 'src')).shell_out(command)
      end
    end

    class DepProject < Project
      def add_dep
        clone('gopath_dep')
      end

      def install
        orig_gopath = ENV['GOPATH']
        ENV['GOPATH'] = "#{project_dir}/gopath_dep"
        shell_out('dep ensure')
        ENV['GOPATH'] = orig_gopath
      end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('gopath_dep', 'src', 'foo-dep')).shell_out(command)
      end
    end

    class BrokenSymLinkDepProject < Project
      def add_dep
        clone('gopath_dep')
      end

      def install; end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('gopath_dep', 'src', 'foo-dep')).shell_out(command)
      end
    end

    class GovendorProject < Project
      def add_dep
        clone('gopath_govendor')
      end

      def install
        orig_gopath = ENV['GOPATH']
        ENV['GOPATH'] = "#{project_dir}/gopath_govendor"
        shell_out('govendor sync')
        ENV['GOPATH'] = orig_gopath
      end

      def shell_out(command)
        ProjectDir.new(Paths.project.join('gopath_govendor', 'src')).shell_out(command)
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
        install_fixture('Podfile')
      end

      def install
        shell_out('pod install')
      end
    end

    class CarthageProject < Project
      def add_dep
        install_fixture('Cartfile')
      end

      def install
        shell_out('carthage bootstrap')
      end
    end

    class SpmProject < Project
      def add_dep
        install_fixture('Package.swift')
      end

      def install
        shell_out('swift package resolve')
      end
    end

    class FlutterProject < Project
      def add_dep
        install_fixture('pubspec.yaml')
      end

      def install
        ENV['PUB_CACHE'] = '~/flutter/.pub-cache/'
        shell_out('flutter pub get')
      end
    end

    class ConanProject < Project
      def add_dep
        install_fixture('conanfile.txt')
      end

      def install
        shell_out('conan install .')
      end
    end

    class RebarProject < Project
      def add_dep
        install_fixture('rebar.config')
      end

      def install
        shell_out('rebar3 get-deps')
      end
    end

    class ErlangMkProject < Project
      def add_dep
        FileUtils.copy_entry(Paths.fixtures.join('erlangmk'), Paths.project)
      end

      def install
        shell_out('make fetch-deps')
      end
    end

    class MixProject < Project
      def add_dep
        install_fixture('mix.exs')
      end

      def install
        shell_out('mix local.hex --force')
        shell_out('mix local.rebar --force')
        shell_out('mix deps.get')
        shell_out('mix deps.compile')
      end
    end

    class MixUmbrellaProject < MixProject
      def add_dep
        FileUtils.copy_entry(Paths.fixtures.join('mix_umbrella'), Paths.project)
      end
    end

    class NugetProject < Project
      def add_dep
        clone('nuget')
      end
    end

    class DotnetProject < Project
      def add_dep
        clone('dotnet')
      end
    end

    class BundlerProject < Project
      def add_dep
        add_to_gemfile("source 'https://rubygems.org'")
        add_to_gemfile("gem 'license_finder', path: #{Paths.root.to_s.inspect}")
      end

      def install
        ::Bundler.with_original_env do
          shell_out('bundle install')
        end
      end

      def depend_on(gem, bundler_options = {})
        add_gem_to_gemfile(gem.name, bundler_options.merge(path: gem.project_dir.to_s))
        install
      end

      private

      def add_gem_to_gemfile(gem_name, options)
        remove_older_gem_from_gemfile(gem_name)
        add_to_gemfile("gem #{gem_name.inspect}, #{options.inspect}")
      end

      def remove_older_gem_from_gemfile(gem_name)
        remove_lines_with_value('Gemfile', gem_name)
      end

      def add_to_gemfile(content)
        add_to_file('Gemfile', content)
      end
    end

    class VendorBundlerProject < Project
      def add_dep
        add_to_gemfile("source 'https://rubygems.org'")
        add_gem_to_gemfile('rake', '12.3.0')
      end

      def install
        ::Bundler.with_original_env do
          shell_out('bundle install --path="vendor/bundle"')
        end
      end

      private

      def add_gem_to_gemfile(gem_name, options)
        add_to_gemfile("gem #{gem_name.inspect}, #{options.inspect}")
      end

      def add_to_gemfile(content)
        add_to_file('Gemfile', content)
      end
    end

    class GitBundlerProject < Project
      def add_dep
        add_to_gemfile("source 'https://rubygems.org'")
        add_to_gemfile("gem 'license_finder', git: #{Paths.root.to_s.inspect}")
      end

      def install
        ::Bundler.with_original_env do
          shell_out('bundle install')
        end
      end

      private

      def add_gem_to_gemfile(gem_name, options)
        add_to_gemfile("gem #{gem_name.inspect}, #{options.inspect}")
      end

      def add_to_gemfile(content)
        add_to_file('Gemfile', content)
      end
    end

    # lives adjacent to a BundlerProject, so has a different lifecycle from other Projects and doesn't inherit
    class GemProject
      def self.create(name, options)
        result = new(name, options[:version])
        result.define(options)
        result
      end

      def self.create_in_path(name, path, options)
        result = new(name, path)
        result.define(options)
        result
      end

      def initialize(name, version = nil, path = nil)
        @name = name
        @path = path
        @file_name = version.nil? ? name : "#{name}-#{version}"
        project_dir.make
      end

      def define(options)
        project_dir.write_file("#{file_name}.gemspec", gemspec_string(options))
      end

      attr_reader :name, :path, :file_name

      def project_dir
        if path
          Paths.project("#{path}/#{file_name}")
        else
          Paths.project(file_name)
        end
      end

      private

      def gemspec_string(options)
        dependencies = Array(options[:dependencies]).map do |dep|
          %(s.add_dependency "#{dep}")
        end.join("\n")

        <<-GEMSPEC
      Gem::Specification.new do |s|
        s.name = "#{name}"
        s.version = "#{options[:version] || '0.0.0'}"
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
    class HtmlReport < SimpleDelegator
      # delegates to the parsed html

      def self.from_string(str)
        new(Capybara.string(str))
      end

      def in_dep(dep_name)
        result = find("##{dep_name}")
        yield result if block_given?
        result
      end

      def approved?(dep_name)
        classes_of(dep_name).include? 'approved'
      end

      def unapproved?(dep_name)
        classes_of(dep_name).include? 'unapproved'
      end

      def titled?(title)
        find('h1').has_content? title
      end

      private

      def classes_of(dep_name)
        in_dep(dep_name)[:class].split(' ')
      end
    end

    class ProjectDir < SimpleDelegator
      # delegates to a Pathname

      def shell_out(command, allow_failures = false)
        Dir.chdir(self) { Shell.run(command, allow_failures) }
      end

      def add_to_file(filename, content)
        join(filename).open('a') { |file| file.puts content }
      end

      def write_file(filename, content)
        join(filename).open('w') { |file| file.write content }
      end

      def remove_lines_with_value(filename, value)
        updated_content = join(filename).open('r').readlines.reject { |line| line.include?(value) }.join
        write_file(filename, updated_content)
      end

      def install_fixture(fixture_name)
        if RUBY_PLATFORM.match?(/mswin|cygwin|mingw/)
          FileUtils.cp(Paths.fixtures.join(fixture_name), join(fixture_name))
        else
          join(fixture_name).make_symlink Paths.fixtures.join(fixture_name)
        end
      end

      def make
        mkpath
      end
    end

    require 'pathname'
    require 'tmpdir'
    module Paths
      extend self

      def root
        # where license_finder is installed
        ProjectDir.new(Pathname.new(__FILE__).dirname.join('..', '..').realpath)
      end

      def fixtures
        root.join('features', 'fixtures')
      end

      def tmpdir
        ProjectDir.new(Pathname.new(Dir.tmpdir))
      end

      def projects
        tmpdir.join('projects')
      end

      def project(name = 'my_app')
        ProjectDir.new(projects.join(name))
      end

      def reset_projects!
        # only destroyed when a test starts, so you can poke around after a failure
        require 'fileutils'
        FileUtils.rmtree(projects) if projects.exist?
        projects.mkpath
      end
    end

    module Shell
      ERROR_MESSAGE_FORMAT = <<ERRORFORMAT
Command failed: `%s`
output: %s
exit: %d
ERRORFORMAT

      def self.run(command, allow_failures = false)
        output = `#{command} 2>&1`
        status = $CHILD_STATUS
        unless status.success? || allow_failures
          message = format ERROR_MESSAGE_FORMAT, command, output.chomp, status.exitstatus
          raise message
        end

        [output, status.exitstatus]
      end
    end
  end
end
