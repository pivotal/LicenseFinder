module LicenseFinder
  class GradlePackage < Package
    attr_reader :name, :version

    def initialize(gradle_dependency, options={})
      super options
      @gradle_dependency = gradle_dependency
      @name = @gradle_dependency["name"].split(":")[1]
      @version = @gradle_dependency["name"].split(":")[2]
    end

    def description
      ""
    end

    def summary
      ""
    end

    def homepage
      ""
    end

    def groups
      []
    end

    def children
      []
    end

    private

    def license_names_from_spec
      @gradle_dependency["license"].map { |l| l["name"] }
    end
  end
end
