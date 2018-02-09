require 'toml'

module LicenseFinder
  class Dep < PackageManager
    def possible_package_paths
      [project_path.join('Gopkg.lock')]
    end

    def current_packages
      toml = TOML.load_file(detected_package_path)
      projects = toml['projects']
      projects.map do |project|
        GoPackage.from_dependency({
                                    'ImportPath' => project['name'],
                                    'InstallPath' => project_path.join('vendor', project['name']),
                                    'Rev' => project['revision']
                                  }, nil, true)
      end
    end

    def self.takes_priority_over
      Go15VendorExperiment
    end

    def self.prepare_command
      'dep ensure -vendor-only'
    end

    def self.package_management_command
      'dep'
    end
  end
end
