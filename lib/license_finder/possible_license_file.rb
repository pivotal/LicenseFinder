module LicenseFinder
  class PossibleLicenseFile
    def initialize(install_path, file_path)
      @install_path = Pathname.new(install_path)
      @file_path = Pathname.new(file_path)
    end

    def file_path
      @file_path.relative_path_from(@install_path).to_s
    end

    def full_file_path
      Pathname.new(@file_path).realpath.to_s
    end

    def file_name
      @file_path.basename.to_s
    end

    def text
      @text ||= @file_path.send(@file_path.respond_to?(:binread) ? :binread : :read)
    end

    def license
      license = License.all.detect do |klass|
        klass.new(text).matches?
      end

      license.pretty_name if license
    end
  end
end
