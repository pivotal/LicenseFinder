# frozen_string_literal: true

module LicenseFinder
  class FlatFile < PackageManager
    def initialize(options = {})
      super
    end

    def current_packages
      deps.map do |dep|
        FlatFilePackage.new(
          dep[:name],
          nil,
          dep[:text],
          homepage: dep[:url]
        )
      end
    end

    def self.package_management_command; end

    def self.prepare_command; end

    def possible_package_paths
      [project_path.join('LICENSES.txt')]
    end

    private

    def deps
      dependencies = []
      File.foreach('LICENSES.txt') do |line|
        if line.start_with?('Package: ')
          dependencies << { name: line.gsub('Package: ', '').chomp, url: '', text: '' }
        elsif line.start_with?('License URL: ')
          dependencies.last[:url] = line.gsub('License URL: ', '').chomp
        elsif line.start_with?('--------') || dependencies.empty?
          next
        else
          dependencies.last[:text] += line
        end
      end
      dependencies
    end
  end
end
