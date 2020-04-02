# frozen_string_literal: true

module LicenseFinder
  class Glide < PackageManager
    def possible_package_paths
      [project_path.join('glide.lock')]
    end

    def current_packages
      detected_path = detected_package_path

      YAML.load_file(detected_path).fetch('imports').map do |package_hash|
        import_path = package_hash.fetch('name')
        license_path = project_path.join('vendor', import_path)

        GoPackage.from_dependency({
                                    'ImportPath' => import_path,
                                    'InstallPath' => license_path,
                                    'Rev' => package_hash.fetch('version')
                                  }, nil, true)
      end
    end

    def self.takes_priority_over
      Go15VendorExperiment
    end

    def package_management_command
      'glide'
    end

    def prepare_command
      'glide install'
    end
  end
end
