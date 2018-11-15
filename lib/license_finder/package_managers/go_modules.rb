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
        'GO111MODULE=on go mod vendor'
      end
    end

    def active?
      sum_file?
    end

    def current_packages
      [read_sum(sum_file_path)].flatten
    end

    private

    def sum_file?
      !sum_file_path.nil?
    end

    def sum_file_path
      Dir[project_path.join(PACKAGES_FILE)].first
    end

    def read_sum(file_path)
      contents = File.read(file_path)
      contents.each_line.map do |line|
        line.include?('go.mod') ? nil : read_package(line)
      end.compact
    end

    def read_package(line)
      parts = line.split(' ')

      name = parts[0]
      version = parts[1]

      info = {
        'ImportPath' => name,
        'Rev' => version
      }

      GoPackage.from_dependency(info, install_prefix(name), true)
    end

    def install_prefix(name)
      return vendor_dir if Dir.exist?(File.join(vendor_dir, name))

      Pathname(ENV['GOPATH'] || ENV['HOME'] + '/go').join('src')
    end

    def vendor_dir
      File.join(project_path, 'vendor')
    end
  end
end
