module LicenseFinder
  class PossibleLicenseFile
    def initialize(package_path, path)
      @package_path = Pathname(package_path)
      @path = Pathname(path)
    end

    # Unused, except in tests
    def file_path
      @path.relative_path_from(@package_path).to_s
    end

    def path
      @path.to_s
    end

    def license
      License.find_by_text(text)
    end

    private

    def text
      @text ||= @path.send(@path.respond_to?(:binread) ? :binread : :read)
    end
  end
end
