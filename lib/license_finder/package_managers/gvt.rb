module LicenseFinder
  class Gvt < PackageManager
    def package_path
      project_path.join('vendor', 'manifest')
    end

    def self.package_management_command
      "gvt"
    end

    def current_packages
      output, success = capture('gvt list -f "{{.Importpath}} {{.Revision}} {{.Repository}}"')
      return [] unless success
      package_lines = output.split("\n")
      package_lines.map do |package_line|
        import_path, revision, repo = package_line.split
        GoPackage.from_dependency({
                                   'ImportPath' => import_path,
                                   'InstallPath' => project_path.join('vendor', import_path),
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
