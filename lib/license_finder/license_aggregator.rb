module LicenseFinder
  class LicenseAggregator
    def initialize(license_finder_config, subprojects)
      @license_finder_config = license_finder_config
      @subprojects = subprojects
    end

    def dependencies
      content = []
      @subprojects.each do |project_path|
        finder = LicenseFinder::Core.new(@license_finder_config.merge(project_path: project_path))
        content << finder.acknowledged.map { |dep| MergedPackage.new(dep, project_path) }
      end
      content.flatten
    end
  end
end