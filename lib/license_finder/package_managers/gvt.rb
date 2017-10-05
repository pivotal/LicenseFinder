module LicenseFinder
  class Gvt < PackageManager
    def package_path
      potential_path_list = Dir.glob project_path.join('*', 'vendor', 'manifest')
      potential_path_list << project_path.join('vendor', 'manifest')
      path = potential_path_list.find { |potential_path| Pathname(potential_path).exist? }

      Pathname(path) unless path.nil?
    end

    def self.package_management_command
      "gvt"
    end

    def current_packages
      split_project_path = project_path.to_s.split('/')
      project_root_depth = split_project_path.length - 1

      split_package_path = package_path.to_s.split('/')
      vendor_dir_depth = split_package_path.index('vendor')
      return [] if (vendor_dir_depth.nil?)
      vendor_dir_parent_depth = vendor_dir_depth - 1

      is_project_root_parent_of_vendor_dir = project_root_depth == vendor_dir_parent_depth
      
      if (is_project_root_parent_of_vendor_dir)
        shell_command = 'gvt list -f "{{.Importpath}} {{.Revision}} {{.Repository}}"'
        path = project_path.join('vendor')
      else
        vendor_dir_parent = split_package_path[vendor_dir_parent_depth]
        shell_command = "cd #{vendor_dir_parent} && gvt list -f \"{{.Importpath}} {{.Revision}} {{.Repository}}\""
        path = project_path.join(vendor_dir_parent, 'vendor')
      end

      output, success = capture(shell_command)
      return [] unless success
      package_lines = output.split("\n")
      package_lines.map do |package_line|
        import_path, revision, repo = package_line.split
        GoPackage.from_dependency({
                                      'ImportPath' => import_path,
                                      'InstallPath' => path.join(import_path),
                                      'Rev' => revision,
                                      'Homepage' => repo
                                  }, nil, true)
      end
    end

    def self.takes_priority_over
      GoVendor
    end
  end
end
