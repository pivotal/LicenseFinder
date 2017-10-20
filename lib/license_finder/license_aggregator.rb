module LicenseFinder
  class LicenseAggregator
    def initialize(license_finder_config, subprojects)
      @license_finder_config = license_finder_config
      @subprojects = subprojects
    end

    def dependencies
      aggregate_packages
        .group_by { |package| [package.name, package.version] }
        .map do |_, packages|
          MergedPackage.new(packages[0].dependency, packages.flat_map(&:subproject_paths))
        end
    end

    private

    def aggregate_packages
      @subprojects.flat_map do |project_path|
        finder = LicenseFinder::Core.new(@license_finder_config.merge(project_path: project_path))
        finder.prepare_projects if @license_finder_config[:prepare]
        finder.acknowledged.map { |dep| MergedPackage.new(dep, [project_path]) }
      end
    end
  end
end
