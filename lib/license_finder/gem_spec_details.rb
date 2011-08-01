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
      return 'MIT' if license_files.any?(&:mit_license_body?)
      return 'Apache 2.0' if license_files.any?(&:apache_license_body?)
      'other'
    end

    def license_files
      Dir.glob(File.join(install_path, '**', LICENSE_FILE_NAMES)).map do |path|
        file = LicenseFile.new(install_path, path)
        file.include_license_text = include_license_text?
        file
      end
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
  end
end
