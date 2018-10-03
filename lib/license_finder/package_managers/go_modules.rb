# frozen_string_literal: true

module LicenseFinder
  class GoModules < PackageManager
    PACKAGES_FILE = 'go.sum'

    class << self
      def takes_priority_over
        Go15VendorExperiment
      end

      def prepare_command
        'go mod vendor'
      end
    end

    def active?
      sum_files?
    end

    def current_packages
      sum_file_paths.uniq.map do |file_path|
        read_sum(file_path)
      end.flatten
    end

    private

    def sum_files?
      sum_file_paths.any?
    end

    def sum_file_paths
      Dir[project_path.join(PACKAGES_FILE)]
    end

    def read_sum(file_path)
      contents = File.read(file_path)
      contents.each_line.map do |line|
        line.include?('go.mod') ? nil : read_package(file_path, line)
      end.compact
    end

    def read_package(file_path, line)
      parts = line.split(' ')
      install_path = File.dirname(file_path)

      name = parts[0]
      version = parts[1]

      Package.new(name, version, install_path: install_path)
    end
  end
end
