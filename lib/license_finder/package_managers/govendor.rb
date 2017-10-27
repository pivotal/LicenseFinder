module LicenseFinder
  class Govendor < PackageManager
    def possible_package_paths
      [project_path.join('vendor', 'vendor.json')]
    end

    def current_packages
      file = File.read(detected_package_path)
      json = JSON.parse(file)
      packages = json['package']
      packages.map do |package|
        GoPackage.from_dependency({
                                    'ImportPath' => package['path'],
                                    'InstallPath' => project_path.join('vendor', package['path']),
                                    'Rev' => package['revision']
                                  }, nil, true)
      end
    end

    def self.takes_priority_over
      Go15VendorExperiment
    end

    def self.package_management_command
      'govendor'
    end

    def self.prepare_method
      'govendor sync'
    end
  end
end
