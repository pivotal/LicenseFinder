# frozen_string_literal: true

require 'license_finder/packages/go_package'

module LicenseFinder
  class GoModules < PackageManager
    PACKAGES_FILE = 'go.sum'

    class << self
      def takes_priority_over
        Go15VendorExperiment
      end
    end

    def prepare_command
      'GO111MODULE=on go mod tidy && GO111MODULE=on go mod vendor'
    end

    def active?
      sum_files?
    end

    def current_packages
      packages = packages_info.map do |package|
        name, version, install_path = package.split(',')
        read_package(install_path, name, version) if install_path.to_s != ''
      end.compact
      packages.reject do |package|
        Pathname(package.install_path).cleanpath == Pathname(project_path).cleanpath
      end
    end

    private

    def packages_info
      info_output, stderr, _status = Cmd.run("GO111MODULE=on go list -m -f '{{.Path}},{{.Version}},{{.Dir}}' all")
      if stderr =~ Regexp.compile("can't compute 'all' using the vendor directory")
        info_output, _stderr, _status = Cmd.run("GO111MODULE=on go list -m -mod=mod -f '{{.Path}},{{.Version}},{{.Dir}}' all")
      end

      info_output.split("\n")
    end

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
