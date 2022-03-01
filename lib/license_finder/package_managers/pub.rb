# frozen_string_literal: true

require 'json'
require 'yaml'

module LicenseFinder
  class Pub < PackageManager
    class PubError < RuntimeError; end

    def current_packages
      unless File.exist?('pubspec.lock')
        raise PubError, "No checked-out Pub packages found.
          Please install your dependencies first."
      end

      if ENV['PUB_CACHE'].nil? || ENV['PUB_CACHE'].eql?('')
        raise PubError, 'While PUB_CACHE environment variable is empty, retrieving package licenses is impossible. Please set the PUB_CACHE env variable (default: ~/.pub)'
      end

      stdout, _stderr, _status = Cmd.run('flutter pub deps --json')
      yaml_deps = JSON.parse(stdout)
      yaml_deps['packages'].map do |dependency|
        package_name = dependency['name']
        subpath = "#{dependency['name']}-#{dependency['version']}"
        package_version = dependency['version']

        project_repo = dependency['source'] == 'git' ? Pathname("#{ENV['PUB_CACHE']}/git/#{dependency['name']}-*/") : Pathname("#{ENV['PUB_CACHE']}/hosted/pub.dartlang.org/#{subpath}")

        homepage = read_repository_home(project_repo)
        homepage = "https://pub.dev/packages/#{package_name}" if homepage.nil? || homepage.empty?
        PubPackage.new(
          package_name,
          package_version,
          license_text(project_repo),
          logger: logger,
          install_path: project_repo,
          homepage: homepage
        )
      end
    end

    def possible_package_paths
      [project_path.join('pubspec.lock')]
    end

    def package_management_command
      'flutter'
    end

    def prepare_command
      'flutter pub get'
    end

    def prepare
      prep_cmd = "#{prepare_command} #{production_flag}"
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(prep_cmd) }

      return if status.success?

      log_errors stderr
      raise "Prepare command '#{prep_cmd}' failed" unless @prepare_no_fail
    end

    private

    def license_text(subpath)
      license_path = license_pattern(subpath).find { |f| File.exist?(f) }
      license_path.nil? ? nil : IO.read(license_path)
    end

    def license_pattern(subpath)
      Dir.glob(subpath.join('LICENSE*'), File::FNM_CASEFOLD)
    end

    def production_flag
      return '' if @ignored_groups.nil?

      @ignored_groups.include?('devDependencies') ? '' : 'no-'
    end

    def read_repository_home(project_repo)
      package_yaml = project_repo.join('pubspec.yaml')
      YAML.load(IO.read(package_yaml))['repository'] if Dir.exist?(project_repo) && File.exist?(package_yaml)
    end
  end
end
