# frozen_string_literal: true

require 'license_finder/package_utils/possible_license_file'

module LicenseFinder
  class NoticeFiles
    CANDIDATE_FILE_NAMES = %w[NOTICE Notice].freeze
    CANDIDATE_PATH_WILDCARD = "*{#{CANDIDATE_FILE_NAMES.join(',')}}*"

    def self.find(install_path, options = {})
      new(install_path).find(options)
    end

    def initialize(install_path)
      @install_path = install_path ? Pathname(install_path) : nil
    end

    def find(options = {})
      paths_of_candidate_files
        .map { |path| PossibleLicenseFile.new(path, options) } # Not really possible license files, but that class has all we need.
    end

    private

    attr_reader :install_path

    def paths_of_candidate_files
      candidate_files_and_dirs
        .flat_map { |path| path.directory? ? path.children : path }
        .reject(&:directory?)
        .uniq
    end

    def candidate_files_and_dirs
      return [] if install_path.nil?

      Pathname.glob(install_path.join('**', CANDIDATE_PATH_WILDCARD))
    end
  end
end
