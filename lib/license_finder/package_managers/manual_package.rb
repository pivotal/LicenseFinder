module LicenseFinder
  class ManualPackage < Package
    def initialize(name, version = nil, options={})
      super options
      @name = name
      @version = version
    end

    attr_reader :name, :version

    def summary
      ""
    end

    def description
      ""
    end

    def homepage
      ""
    end

    def children
      []
    end

    def groups
      []
    end

    private

    def licenses_from_spec
      Set.new
    end

    def licenses_from_files
      Set.new
    end
  end
end
