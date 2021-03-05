# frozen_string_literal: true

require 'tomlrb'

module LicenseFinder
  class Dep < PackageManager
    def possible_package_paths
      [project_path.join('Gopkg.lock')]
    end

    def current_packages
      toml = Tomlrb.load_file(detected_package_path)
      projects = toml['projects']

      return [] if projects.nil?

      projects.map do |project|
        GoPackage.from_dependency({
                                    'ImportPath' => project['name'],
                                    'InstallPath' => project_path.join('vendor', project['name']),
                                    'Rev' => project['revision'],
                                    'Homepage' => repo_name(project['name'])
                                  }, nil, true)
      end
    end

    def repo_name(name)
      name.split('/')[0..2].join('/')
    end

    def self.takes_priority_over
      Go15VendorExperiment
    end

    def prepare_command
      'dep ensure -vendor-only'
    end

    def package_management_command
      'dep'
    end
  end
end
