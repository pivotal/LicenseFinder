module LicenseFinder
  class Govendor < PackageManager
    def package_path
      project_path.join('vendor', 'vendor.json')
    end

    def current_packages
      file = File.read(package_path)
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
  end
end