module LicenseFinder
  class BundledGem
    LICENSE_FILE_NAMES = %w(LICENSE License Licence COPYING README Readme ReadMe)

    attr_reader :parents

    def initialize(spec, bundler_dependency = nil)
      @spec = spec
      @bundler_dependency = bundler_dependency
    end

    def name
      "#{dependency_name} #{dependency_version}"
    end

    def parents
      @parents ||= []
    end

    def dependency_name
      @spec.name
    end

    def dependency_version
      @spec.version.to_s
    end

    def children
      @children ||= @spec.dependencies.collect(&:name)
    end

    def to_dependency
      @dependency ||= LicenseFinder::Dependency.new(
        'name' => @spec.name,
        'version' => @spec.version.to_s,
        'license' => determine_license,
        'license_files' => license_files.map(&:file_path),
        'source' => 'bundle',
        'bundler_groups' => (@bundler_dependency.groups if @bundler_dependency),
        'summary' => @spec.summary,
        'description' => @spec.description,
        'homepage' => @spec.homepage,
        'children' => children,
        'parents'  => parents
      )
    end

    def determine_license
      return @spec.license if @spec.license

      license_files.map(&:license).compact.first || 'other'
    end

    def license_files
      paths_with_license_names = find_matching_files(LICENSE_FILE_NAMES)
      paths_for_license_files = paths_with_license_names.map do |path|
        File.directory?(path) ? paths_for_files_in_license_directory(path) : path
      end.flatten.uniq
      get_files_for_paths(paths_for_license_files)
    end

    def install_path
      @spec.full_gem_path
    end

    def sort_order
      dependency_name.downcase
    end

    private

    def find_matching_files(names)
      Dir.glob(File.join(install_path, '**', "*{#{names.join(',')}}*"))
    end

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
