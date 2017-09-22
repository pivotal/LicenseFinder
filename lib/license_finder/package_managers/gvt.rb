module LicenseFinder
  class Gvt < PackageManager
    def package_path
      project_path.join('vendor', 'manifest')
    end

    def self.package_management_command
      "gvt"
    end

    def current_packages
      []
    end
  end
end
