require 'license_finder/shared_helpers/common_path'
module LicenseFinder
  class Gvt < PackageManager
    def possible_package_paths
      potential_path_list = Dir.glob project_path.join('*', 'vendor', 'manifest')
      potential_path_list << project_path.join('vendor', 'manifest')
      potential_path_list.map { |path| Pathname path }
    end

    def self.package_management_command
      'gvt'
    end

    def self.prepare_command
      'gvt restore'
    end

    def current_packages
      split_project_path = project_path.to_s.split('/')
      project_root_depth = split_project_path.length - 1

      split_package_path = detected_package_path.to_s.split('/')
      vendor_dir_depth = split_package_path.index('vendor')
      return [] if vendor_dir_depth.nil?
      vendor_dir_parent_depth = vendor_dir_depth - 1

      is_project_root_parent_of_vendor_dir = project_root_depth == vendor_dir_parent_depth

      if is_project_root_parent_of_vendor_dir
        shell_command = 'gvt list -f "{{.Importpath}} {{.Revision}} {{.Repository}}"'
        path = project_path.join('vendor')
      else
        vendor_dir_parent = split_package_path[vendor_dir_parent_depth]
        shell_command = "cd #{vendor_dir_parent} && gvt list -f \"{{.Importpath}} {{.Revision}} {{.Repository}}\""
        path = project_path.join(vendor_dir_parent, 'vendor')
      end

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
        paths = CommonPathHelper.shortest_common_paths(info['paths'])

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
