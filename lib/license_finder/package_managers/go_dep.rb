# frozen_string_literal: true

require 'json'

module LicenseFinder
  class GoDep < PackageManager
    OLD_GODEP_VENDOR_PATH = 'Godeps/_workspace/src'
    GODEP_VENDOR_PATH = 'vendor'

    def initialize(options = {})
      super
      @full_version = options[:go_full_version]
    end

    def current_packages
      packages_from_json(detected_package_path.read)
      # godep includes subpackages as a seperate dependency, we can de-dup that
    end

    def self.takes_priority_over
      Go15VendorExperiment
    end

    def possible_package_paths
      [project_path.join('Godeps/Godeps.json')]
    end

    def package_management_command
      'godep'
    end

    private

    def install_prefix
      @install_prefix ||= if project_path.join(OLD_GODEP_VENDOR_PATH).directory?
                            project_path.join(OLD_GODEP_VENDOR_PATH)
                          elsif project_path.join(GODEP_VENDOR_PATH).directory?
                            project_path.join(GODEP_VENDOR_PATH)
                          else
                            download_dependencies
                            Pathname(ENV['GOPATH'] ? ENV['GOPATH'] + '/src' : ENV['HOME'] + '/go/src')
                          end
    end

    def download_dependencies
      command = "#{package_management_command} restore"
      _, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" if !status.success? && status.exitstatus != 1
    end

    def packages_from_json(json_string)
      all_packages = JSON.parse(json_string)['Deps']

      return [] unless all_packages

      packages_grouped_by_revision = all_packages.group_by { |package| package['Rev'] }
      result = []

      packages_grouped_by_revision.each do |_sha, packages_in_group|
        all_paths_in_group = packages_in_group.map { |p| p['ImportPath'] }
        common_paths = CommonPathHelper.longest_common_paths(all_paths_in_group)
        package_info = packages_in_group.first

        common_paths.each do |common_path|
          dependency_info_hash = {
            'Homepage' => common_path,
            'ImportPath' => common_path,
            'InstallPath' => package_info['InstallPath'],
            'Rev' => package_info['Rev']
          }

          result << GoPackage.from_dependency(dependency_info_hash,
                                              install_prefix,
                                              @full_version)
        end
      end
      result
    end
  end
end
