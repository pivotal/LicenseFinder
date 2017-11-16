module LicenseFinder
  class LicenseAggregator
    def initialize(license_finder_config, aggregate_paths)
      @license_finder_config = license_finder_config
      @aggregate_paths = aggregate_paths
    end

    def dependencies
       aggregate_packages
    end

    def any_packages?
      finders.map{|finder| finder.any_packages?}.reduce(:|)
    end

    def unapproved
      aggregate_packages.reject(&:approved?)
    end

    def blacklisted
      aggregate_packages.select(&:blacklisted?)
    end

    private

    def finders
      return @finders unless @finders.nil?
      if @aggregate_paths.nil?
        @finders = [LicenseFinder::Core.new(@license_finder_config)]
      else
        @finders = @aggregate_paths.map { |path|
          LicenseFinder::Core.new(@license_finder_config.merge(project_path: path)) }
      end
    end

    def aggregate_packages
      return @packages unless @packages.nil?
      all_packages = finders.flat_map do |finder|
        finder.prepare_projects if @license_finder_config[:prepare]
        finder.acknowledged.map { |dep| MergedPackage.new(dep, [finder.project_path]) }
      end
      @packages = all_packages.group_by { |package| [package.name, package.version] }
          .map do |_, packages|
        MergedPackage.new(packages[0].dependency, packages.flat_map(&:aggregate_paths))
      end
    end
  end
end
