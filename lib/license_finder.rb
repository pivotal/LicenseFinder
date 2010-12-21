module LicenseFinder
  def self.from_bundler
    require 'bundler'
    Bundler.load.specs.map { |spec| Finder.new(spec) }.sort_by &:sort_order
  end

  class Finder
    LICENSE_FILE_NAMES = '*{LICENSE,License,COPYING}*' # follows Dir.glob format

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

    def license_files
      Dir.glob(File.join(install_path, '**', LICENSE_FILE_NAMES))
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
        'license_files' => license_file_hashes
      }
    end

    def sort_order
      dependency_name.downcase
    end

    private

    def license_file_hashes
      license_files.map do |file|
        h = { 'file' => file }
        h['text'] = license_text(file) if include_license_text?
        h
      end
    end

    attr_writer :include_license_text

    def include_license_text?
      @include_license_text
    end

    def license_text(license_file)
      File.read(license_file)
    end
  end
end
