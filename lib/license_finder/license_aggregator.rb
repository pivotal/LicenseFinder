module LicenseFinder
  class LicenseAggregator
    def initialize(license_finder_config, subprojects)
      @license_finder_config = license_finder_config
      @subprojects = subprojects
    end

    def dependencies
      [].tap do |deps|
        grouped_by_name = aggregate_packages.group_by { |package| [package.name, package.version] }
        grouped_by_name.each do |name, packages|
          deps << MergedPackage.new(packages[0].dependency, packages.flat_map(&:subproject_paths))
        end
      end
    end

    private

    def aggregate_packages
      content = []
      @subprojects.each do |project_path|
        finder = LicenseFinder::Core.new(@license_finder_config.merge(project_path: project_path))
        content << finder.acknowledged.map { |dep| MergedPackage.new(dep, [project_path]) }
      end
      content.flatten
    end
  end
end