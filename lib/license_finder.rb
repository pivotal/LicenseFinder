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

    def install_path
      spec.full_gem_path
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

    def to_s(include_license_text = true)
      result = ''
      result << "#{dependency_name} #{dependency_version}\n"
      result << "\t(installed at #{install_path})\n"
      license_files.each do |license_file|
        result << "\t#{license_file}\n"
        result << "#{license_text(license_file)}\n\n" if include_license_text
      end
      result
    end

    def sort_order
      dependency_name.downcase
    end

    private

    def license_text(license_file)
      File.read(license_file)
    end
  end
end
