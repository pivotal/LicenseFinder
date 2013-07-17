module LicenseFinder
  class BundledGem
    attr_reader :parents, :spec, :bundler_dependency, :children

    def initialize(spec, bundler_dependency = nil)
      @spec = spec
      @bundler_dependency = bundler_dependency
      @children = []
    end

    def name
      "#{dependency_name} #{dependency_version}"
    end

    def parents
      @parents ||= []
    end

    def dependency_name
      @spec.name
    end

    def dependency_version
      @spec.version.to_s
    end

    def groups
      @groups ||= bundler_dependency ? bundler_dependency.groups : []
    end

    def license
      @license ||= determine_license
    end

    def sort_order
      dependency_name.downcase
    end

    def license_files
      PossibleLicenseFiles.new(@spec.full_gem_path).find
    end

    def children=(childs)
      @children = childs
    end

    private

    def determine_license
      return @spec.license if @spec.license

      license_files.map(&:license).compact.first || 'other'
    end
  end
end
