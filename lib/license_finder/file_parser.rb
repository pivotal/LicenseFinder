module LicenseFinder
  class FileParser
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
      @text ||= @file_path.read
    end
  end
end
