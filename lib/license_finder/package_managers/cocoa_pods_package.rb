module LicenseFinder
  class CocoaPodsPackage < Package
    attr_reader :name, :version
    attr_reader :summary, :description, :homepage

    def initialize(name, version, license_text)
      @name = name
      @version = version
      @license_text = license_text
    end

    def groups; []; end
    def children; []; end

    def licenses
      [License.find_by_text(@license_text.to_s) || default_license].to_set
    end
  end
end
