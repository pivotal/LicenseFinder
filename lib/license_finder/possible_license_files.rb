module LicenseFinder
  class PossibleLicenseFiles
    LICENSE_FILE_NAMES = %w(LICENSE License Licence COPYING README Readme ReadMe)

    def self.find(install_path)
      new(install_path).find
    end

    def initialize(install_path)
      @install_path = install_path
    end

    def find
      paths_for_license_files.map do |path|
        get_file_for_path(path)
      end
    end

    private

    attr_reader :install_path

    def paths_for_license_files
      find_matching_files.map do |path|
        File.directory?(path) ? paths_for_files_in_license_directory(path) : path
      end.flatten.uniq
    end

    def find_matching_files
      Dir.glob(File.join(install_path, '**', "*{#{LICENSE_FILE_NAMES.join(',')}}*"))
    end

    def paths_for_files_in_license_directory(path)
      entries_in_directory = Dir::entries(path).reject { |p| p.match(/^(\.){1,2}$/) }
      entries_in_directory.map { |entry_name| File.join(path, entry_name) }
    end

    def get_file_for_path(path)
      PossibleLicenseFile.new(install_path, path)
    end
  end
end
