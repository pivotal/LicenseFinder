# frozen_string_literal: true

require 'license_finder/package_utils/possible_copyright_file'

module LicenseFinder
  class CopyrightFiles
    include SharedHelpers

    CANDIDATE_FILE_NAMES = %w[License Licence COPYING README NOTICE COPYRIGHT].freeze
    CANDIDATE_PATH_WILDCARD = "*{#{CANDIDATE_FILE_NAMES.join(',')}}*"

    def self.find(install_path, options = {})
      new(install_path).find(options)
    end

    def initialize(install_path)
      @install_path = install_path ? Pathname(install_path) : nil
    end

    def find(options = {})
      paths_of_candidate_files
        .map { |path| PossibleCopyrightFile.new(path, options) }
        .reject { |file| file.copyright.nil? }
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

      candidates = Pathname.glob(install_path.join('**', CANDIDATE_PATH_WILDCARD), File::FNM_CASEFOLD)
      candidates |= detect_in_path_files unless candidates.any?
      candidates
    end

    def detect_in_path_files
      stdout, _stderr, status = Cmd.run("grep -E '^.*(copyright|\(c\)).*$' -I -irn #{@install_path} | cut -d ':' -f 1")
      return [] unless status.success?

      stdout.strip.split("\n").map { |file| Pathname(file) }
    end
  end
end
