module LicenseFinder
  class PossibleLicenseFiles
    LICENSE_FILE_NAMES = %w(LICENSE License Licence COPYING README Readme ReadMe)

    def self.find(install_path)
      new(install_path).find
    end

    def initialize(install_path)
      @install_path = Pathname(install_path)
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
        path.directory? ? path.children : path
      end.flatten.uniq
    end

    def find_matching_files
      Pathname.glob(install_path.join('**', "*{#{LICENSE_FILE_NAMES.join(',')}}*"))
    end

    def get_file_for_path(path)
      PossibleLicenseFile.new(install_path, path)
    end
  end
end
