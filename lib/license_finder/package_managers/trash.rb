# frozen_string_literal: true

module LicenseFinder
  class Trash < PackageManager
    class << self
      def package_management_command
        'trash'
      end

      def takes_priority_over
        Go15VendorExperiment
      end
    end

    def prepare_command
      'trash'
    end

    def possible_package_paths
      [project_path.join('vendor.conf')]
    end

    def current_packages
      dependencies_path = project_path.join('trash.lock')

      YAML.load_file(dependencies_path).fetch('import').map do |package_hash|
        import_path = package_hash.fetch('package')
        license_path = project_path.join('vendor', import_path)

        GoPackage.from_dependency({
                                    'ImportPath' => import_path,
                                    'InstallPath' => license_path,
                                    'Rev' => package_hash.fetch('version'),
                                    'Homepage' => repo_name(import_path)
                                  }, nil, true)
      end
    end

    def repo_name(name)
      name.split('/')[0..2].join('/')
    end
  end
end
