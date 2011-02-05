module LicenseFinder
  class ReadmeFile < FileParser
    def mentions_license?
      !!(text =~ /license/im)
    end
    
    def to_hash
      { 'file_name' => file_path, 'mentions_license' => mentions_license? }
    end
  end
end
