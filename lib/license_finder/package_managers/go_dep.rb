require 'json'

module LicenseFinder
  class GoDep < PackageManager
    def initialize(options = {})
      super
      @full_version = options[:go_full_version]
    end

    def current_packages
      json = JSON.parse(detected_package_path.read)
      # godep includes subpackages as a seperate dependency, we can de-dup that

      dependencies_info = json['Deps'].map do |dep_json|
        {
          'Homepage' => homepage(dep_json),
          'ImportPath' => import_path(dep_json),
          'InstallPath' => dep_json['InstallPath'],
          'Rev' => dep_json['Rev']
        }
      end
      dependencies_info.uniq.map do |info|
        GoPackage.from_dependency(info, install_prefix, @full_version)
      end
    end

    def possible_package_paths
      [project_path.join('Godeps/Godeps.json')]
    end

    def self.package_management_command
      'godep'
    end

    private

    def install_prefix
      go_path = if workspace_dir.directory?
                  workspace_dir
                else
                  Pathname(ENV['GOPATH'] || ENV['HOME'] + '/go')
                end
      go_path.join('src')
    end

    def workspace_dir
      project_path.join('Godeps/_workspace')
    end

    def homepage(dependency_json)
      import_path dependency_json
    end

    def import_path(dependency_json)
      import_path = dependency_json['ImportPath']
      return import_path unless import_path.include?('github.com')

      import_path.split('/')[0..2].join('/')
    end
  end
end
