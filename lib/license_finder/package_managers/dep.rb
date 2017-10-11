require 'toml'

module LicenseFinder
  class Dep < PackageManager
    def package_path
      project_path.join('Gopkg.lock')
    end

    def current_packages
      toml = TOML.load_file(package_path)
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
  end
end