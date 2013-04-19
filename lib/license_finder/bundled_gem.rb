module LicenseFinder
  class BundledGem
    attr_reader :parents, :spec, :bundler_dependency

    def initialize(spec, bundler_dependency = nil)
      @spec = spec
      @bundler_dependency = bundler_dependency
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

    def children
      @children ||= @spec.dependencies.collect(&:name)
    end

    def determine_license
      return @spec.license if @spec.license

      license_files.map(&:license).compact.first || 'other'
    end

    def license_files
      PossibleLicenseFiles.new(@spec.full_gem_path).find
    end

    def sort_order
      dependency_name.downcase
    end

    def save_as_dependency
      BundledGemSaver.find_or_initialize_by_name(@spec.name, self).save
    end
  end
end
