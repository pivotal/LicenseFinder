# frozen_string_literal: true

require 'license_finder/shared_helpers/common_path'
require 'json'

module LicenseFinder
  class Govendor < PackageManager
    def possible_package_paths
      [project_path.join('vendor', 'vendor.json')]
    end

    def current_packages
      file = File.read(detected_package_path)
      packages = packages_from_json(file)
      packages.map do |package|
        GoPackage.from_dependency({
                                    'ImportPath' => package[:path],
                                    'InstallPath' => project_path.join('vendor', package[:path]),
                                    'Rev' => package[:sha]
                                  }, nil, true)
      end
    end

    def self.takes_priority_over
      Go15VendorExperiment
    end

    def package_management_command
      'govendor'
    end

    def prepare_command
      'govendor sync'
    end

    private

    def packages_from_json(json_string)
      data = JSON.parse(json_string)
      packages = data['package']

      packages_by_sha = {}
      packages_with_no_sha = []

      packages.each do |package|
        package_path = package['origin'] || package['path']
        package_revision = package['revision']

        if !package_is_versioned?(package)
          packages_with_no_sha << { sha: '', path: package_path }
        elsif packages_by_sha[package_revision].nil?
          packages_by_sha[package_revision] = [package_path]
        else
          packages_by_sha[package_revision] << package_path
        end
      end

      result = packages_with_no_sha
      packages_by_sha.each do |sha, paths|
        common_paths = CommonPathHelper.longest_common_paths(paths)
        common_paths.each { |cp| result << { sha: sha, path: cp } }
      end

      result
    end

    def package_is_versioned?(package)
      package_revision = package['revision']

      !package_revision.nil? && !package_revision.empty?
    end
  end
end
