require 'license_finder/packages/possible_license_file'

module LicenseFinder
  class LicenseFiles
    CANDIDATE_FILE_NAMES = %w(LICENSE License Licence COPYING README Readme ReadMe)
    CANDIDATE_PATH_WILDCARD = "*{#{CANDIDATE_FILE_NAMES.join(',')}}*"

    def self.find(install_path)
      new(install_path).find
    end

    def initialize(install_path)
      @install_path = install_path ? Pathname(install_path) : nil
    end

    def find
      paths_of_candidate_files
        .map { |path| PossibleLicenseFile.new(path) }
        .reject { |file| file.license.nil? }
    end

    private

    attr_reader :install_path

    def paths_of_candidate_files
      candidate_files_and_dirs
        .flat_map { |path| path.directory? ? path.children : path }
        .uniq
    end

    def candidate_files_and_dirs
      return [] if install_path.nil?
      Pathname.glob(install_path.join('**', CANDIDATE_PATH_WILDCARD))
    end
  end
end
