# frozen_string_literal: true

require 'json'
require 'tempfile'

module LicenseFinder
  class PNPM < PackageManager
    def initialize(options = {})
      super
      @pnpm_options = options[:pnpm_options]
    end

    SHELL_COMMAND = 'pnpm licenses list --json --long'

    def possible_package_paths
      [project_path.join('pnpm-lock.yaml')]
    end

    def self.takes_priority_over
      NPM
    end

    def current_packages
      # check if the minimum version of PNPM is met
      raise 'The minimum PNPM version is not met, requires 7.17.0 or later' unless supported_pnpm?

      # check if the project directory has workspace file
      cmd = PNPM::SHELL_COMMAND.to_s
      cmd += ' --no-color'
      cmd += ' --recursive' unless project_has_workspaces == false
      cmd += " --dir #{project_path}" unless project_path.nil?
      cmd += " #{@pnpm_options}" unless @pnpm_options.nil?

      stdout, stderr, status = Cmd.run(cmd)
      raise "Command '#{cmd}' failed to execute: #{stderr}" unless status.success?

      json_objects = JSON.parse(stdout)
      get_pnpm_packages(json_objects)
    end

    def get_pnpm_packages(json_objects)
      packages = []
      incompatible_packages = []

      json_objects.map do |_, value|
        value.each do |pkg|
          name = pkg['name']
          version = pkg['version']
          license = pkg['license']
          homepage = pkg['vendorUrl']
          author = pkg['vendorName']
          module_path = pkg['path']

          package = PNPMPackage.new(
            name,
            version,
            spec_licenses: [license],
            homepage: homepage,
            authors: author,
            install_path: module_path
          )
          packages << package
        end
      end

      packages + incompatible_packages.uniq
    end

    def package_management_command
      'pnpm'
    end

    def prepare_command
      'pnpm install --no-lockfile --ignore-scripts'
    end

    def prepare
      prep_cmd = "#{prepare_command}#{production_flag}"
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(prep_cmd) }

      return if status.success?

      log_errors stderr
      raise "Prepare command '#{prep_cmd}' failed" unless @prepare_no_fail
    end

    private

    def project_has_workspaces
      Dir.chdir(project_path) do
        return File.file?('pnpm-workspace.yaml')
      end
    end

    # PNPM introduced the licenses command in 7.17.0
    def supported_pnpm?
      Dir.chdir(project_path) do
        version_string, stderr_str, status = Cmd.run('pnpm --version')
        raise "Command 'pnpm -v' failed to execute: #{stderr_str}" unless status.success?

        version = version_string.split('.').map(&:to_i)
        major = version[0]
        minor = version[1]
        patch = version[1]

        return true if major > 7
        return true if major == 7 && minor > 17
        return true if major == 7 && minor == 17 && patch >= 0

        return false
      end
    end

    def production_flag
      return '' if @ignored_groups.nil?

      @ignored_groups.include?('devDependencies') ? ' --prod' : ''
    end
  end
end
