module LicenseFinder
  class PossibleLicenseFile
    def initialize(path)
      @path = Pathname(path)
    end

    def path
      @path.to_s
    end

    def license
      License.find_by_text(text)
    end

    def text
      @text ||= (@path.respond_to?(:binread) ? @path.binread : @path.read)
    end
  end
end
