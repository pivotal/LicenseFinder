module LicenseFinder
  class GemSpecDetails
    LICENSE_FILE_NAMES = '*{LICENSE,License,COPYING,README,Readme,ReadMe}*' # follows Dir.glob format
    README_FILE_NAMES = '*{README,Readme,ReadMe}*' # follows Dir.glob format

    def initialize(spec, whitelist = [])
      @spec = spec
      @whitelist = whitelist
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
      license = determine_license
      @dependency ||= Dependency.new(@spec.name, @spec.version, license, @whitelist.include?(license), '', '', license_files.map(&:full_file_path), readme_files.map(&:full_file_path))
    end

    def determine_license
      return @spec.license if @spec.license
      return 'MIT' if license_files.any?{|f| f.mit_license_body? || f.mit_license_header?}
      return 'Apache 2.0' if license_files.any?(&:apache_license_body?)
      return 'GPLv2' if license_files.any?(&:gplv2_license_body?)
      return 'ruby' if license_files.any?(&:ruby_license_body?)
      return 'LGPL' if license_files.any?(&:lgpl_license_body?)
      'other'
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
        file = LicenseFile.new(install_path, path)
        file.include_license_text = include_license_text?
        file
      end
    end

    def install_path
      spec.full_gem_path
    end

    def to_s(include_license_text = true)
      self.include_license_text = include_license_text

      { name => to_hash }.to_yaml
    end

    def to_hash
      {
        'dependency_name' => dependency_name,
        'dependency_version' => dependency_version,
        'install_path' => install_path,
        'license_files' => license_files.map { |file| file.to_hash }
      }
    end

    def sort_order
      dependency_name.downcase
    end

    private

    attr_writer :include_license_text

    def include_license_text?
      @include_license_text
    end

    def get_file_for_path(path)
      file = LicenseFile.new(install_path, path)
      file.include_license_text = include_license_text?
      file
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
