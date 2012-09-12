module LicenseFinder
  class GemSpecDetails
    LICENSE_FILE_NAMES = '*{LICENSE,License,Licence,COPYING,README,Readme,ReadMe}*' # follows Dir.glob format
    README_FILE_NAMES = '*{README,Readme,ReadMe}*' # follows Dir.glob format

    def initialize(spec)
      @spec = spec
    end

    attr_reader :spec

    def name
      "#{dependency_name} #{dependency_version}"
    end

    def dependency_name
      spec.name
    end

    def dependency_version
      spec.version.to_s
    end

    def dependency
      @dependency ||= Dependency.new(
        'name' => @spec.name,
        'version' => @spec.version.to_s,
        'license' => determine_license,
        'license_files' => license_files.map(&:full_file_path),
        'readme_files' => readme_files.map(&:full_file_path),
        'source' => 'bundle',
        'summary' => @spec.summary,
        'description' => @spec.description,
      )
    end

    def determine_license
      return @spec.license if @spec.license

      license_files.map(&:license).compact.first || 'other'
    end

    def license_files
      paths_with_license_names = Dir.glob(File.join(install_path, '**', LICENSE_FILE_NAMES))
      paths_for_license_files = paths_with_license_names.map do |path|
        File.directory?(path) ? paths_for_files_in_license_directory(path) : path
      end.flatten.uniq
      get_files_for_paths(paths_for_license_files)
    end

    def readme_files
      Dir.glob(File.join(install_path, '**', README_FILE_NAMES)).map do |path|
        get_file_for_path path
      end
    end

    def install_path
      spec.full_gem_path
    end

    def sort_order
      dependency_name.downcase
    end

    private

    def get_file_for_path(path)
      PossibleLicenseFile.new(install_path, path)
    end

    def paths_for_files_in_license_directory(path)
      entries_in_directory = Dir::entries(path).reject { |p| p.match(/^(\.){1,2}$/) }
      entries_in_directory.map { |entry_name| File.join(path, entry_name) }
    end

    def get_files_for_paths(paths_for_license_files)
      paths_for_license_files.map do |path|
        get_file_for_path(path)
      end
    end
  end
end
