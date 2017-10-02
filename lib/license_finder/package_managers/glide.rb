module LicenseFinder
  class Glide < PackageManager
    def package_path
      project_path.join('src', 'glide.lock')
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
      GoVendor
    end
  end
end
