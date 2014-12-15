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

    def ==(other)
      eql? other
    end

    def eql?(other)
      name == other.name # && version.to_s == other.version.to_s # ignore version
    end

    def hash
      name.hash # ^ version.to_s.hash # ignore version
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
