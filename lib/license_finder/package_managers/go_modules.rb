# frozen_string_literal: true

require 'license_finder/packages/go_package'

module LicenseFinder
  class GoModules < PackageManager
    PACKAGES_FILE = 'go.sum'

    class << self
      def takes_priority_over
        Go15VendorExperiment
      end

      def prepare_command
        'GO111MODULE=on go mod tidy && GO111MODULE=on go mod vendor'
      end
    end

    def active?
      sum_files?
    end

    def current_packages
      info_output, _stderr, _status = Cmd.run("GO111MODULE=on go list -m -mod=vendor -f '{{.Path}},{{.Version}},{{.Dir}}' all")
      packages_info = info_output.split("\n")
      packages = packages_info.map do |package|
        name, version, install_path = package.split(',')
        read_package(install_path, name, version)
      end
      packages.reject do |package|
        Pathname(package.install_path).cleanpath == Pathname(project_path).cleanpath
      end
    end

    private

    def sum_files?
      sum_file_paths.any?
    end

    def sum_file_paths
      Dir[project_path.join(PACKAGES_FILE)]
    end

    def read_package(install_path, name, version)
      info = {
        'ImportPath' => name,
        'InstallPath' => install_path,
        'Rev' => version
      }

      GoPackage.from_dependency(info, nil, true)
    end
  end
end
