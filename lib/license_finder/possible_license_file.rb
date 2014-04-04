module LicenseFinder
  class PossibleLicenseFile
    def initialize(install_path, file_path)
      @install_path = Pathname.new(install_path)
      @file_path = Pathname.new(file_path)
    end

    # Unused, except in tests, but might be useful if LF ever reports the
    # locations of all the files it searched.
    def file_path
      @file_path.relative_path_from(@install_path).to_s
    end

    def text
      @text ||= @file_path.send(@file_path.respond_to?(:binread) ? :binread : :read)
    end

    def license
      License.find_by_text(text).pretty_name
    end
  end
end
