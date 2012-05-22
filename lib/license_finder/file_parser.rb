module LicenseFinder
  class FileParser
    def initialize(install_path, file_path)
      @install_path = Pathname.new(install_path)
      @file_path = Pathname.new(file_path)
    end

    def file_path
      @file_path.relative_path_from(@install_path).to_s
    end

    def full_file_path
      @file_path.realpath.to_s
    end

    def file_name
      @file_path.basename.to_s
    end

    def text
      @text ||= @file_path.send((@file_path.respond_to? :binread) ? :binread : :read)
    end
    
    private
    
    def on_single_line(text)
      text.gsub(/\s+/, ' ').gsub("'", "\"")
    rescue
      ''
    end
    
    def without_punctuation(text)
      text.gsub('#', '').gsub(' ', '')
    end
    
    def cleaned_up(text)
      without_punctuation(on_single_line(text))
    end
  end
end
