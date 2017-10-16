module LicenseFinder
  class Glide < PackageManager
    def package_path
      return alternate_package_path if alternate_package_path
      project_path.join('src', 'glide.lock')
    end

    def alternate_package_path
      path = project_path.join('glide.lock')
      return nil unless File.exist? path
      path
    end

    def current_packages
      YAML.load_file(package_path).fetch('imports').map do |package_hash|
        import_path = package_hash.fetch('name')
        GoPackage.from_dependency({
                                   'ImportPath' => import_path,
                                   'InstallPath' => project_path.join('src', 'vendor', import_path),
                                   'Rev' => package_hash.fetch('version')
                                  }, nil, true)
      end
    end

    def self.takes_priority_over
      Go15VendorExperiment
    end
  end
end
