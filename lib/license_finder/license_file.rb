module LicenseFinder
  class LicenseFile < FileParser
    MIT_LICENSE_TEXT = (LicenseFinder::ROOT_PATH + 'templates/MIT').read
    
    def body_type
      mit_license_body? ? 'mit' : 'other'
    end

    def mit_license_body?
      !!on_single_line(text).index(on_single_line(MIT_LICENSE_TEXT))
    end

    def to_hash
      h = { 'file_name' => file_path, 'body_type' => body_type }
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
