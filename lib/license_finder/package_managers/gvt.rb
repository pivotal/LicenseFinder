# frozen_string_literal: true

require 'license_finder/shared_helpers/common_path'

module LicenseFinder
  class Gvt < PackageManager
    def possible_package_paths
      potential_path = project_path.join('vendor', 'manifest')
      [Pathname(potential_path)]
    end

    def package_management_command
      'gvt'
    end

    def prepare_command
      'gvt restore'
    end

    def current_packages
      shell_command = "cd #{project_path} && gvt list -f \"{{.Importpath}} {{.Revision}} {{.Repository}}\""
      path = project_path.join(project_path, 'vendor')

      stdout, _stderr, status = Cmd.run(shell_command)
      return [] unless status.success?

      packages_from_output(stdout, path)
    end

    def self.takes_priority_over
      Go15VendorExperiment
    end

    private

    def packages_from_output(output, path)
      package_lines = output.split("\n")
      packages_by_sha = {}
      package_lines.each do |p|
        package_path, sha, repo = p.split
        if packages_by_sha[sha].nil?
          packages_by_sha[sha] = {}
          packages_by_sha[sha]['paths'] = [package_path]
          packages_by_sha[sha]['repo'] = repo
        else
          packages_by_sha[sha]['paths'] << package_path
        end
      end

      result = []
      packages_by_sha.each do |sha, info|
        paths = CommonPathHelper.longest_common_paths(info['paths'])

        paths.each { |p| result << [sha, p, info['repo']] }
      end

      result.map do |package_info|
        sha, import_path, repo = package_info

        GoPackage.from_dependency({
                                    'ImportPath' => import_path,
                                    'InstallPath' => path.join(import_path),
                                    'Rev' => sha,
                                    'Homepage' => repo
                                  }, nil, true)
      end
    end
  end
end
