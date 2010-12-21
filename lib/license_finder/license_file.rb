require 'pathname'

module LicenseFinder
  class LicenseFile
    def initialize(install_path, file_path)
      @install_path = Pathname.new(install_path)
      @file_path = Pathname.new(file_path)
    end

    def file_path
      @file_path.relative_path_from(@install_path).to_s
    end

    def file_name
      @file_path.basename.to_s
    end

    def text
      @file_path.read
    end

    def to_hash
      h = { 'file_name' => file_path }
      h['text'] = text if include_license_text?
      h
    end

    attr_writer :include_license_text

    private

    def include_license_text?
      @include_license_text
    end
  end
end
