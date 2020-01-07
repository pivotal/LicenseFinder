# frozen_string_literal: true

module LicenseFinder
  class LicenseAggregator
    def initialize(config, aggregate_paths)
      @config = config
      @aggregate_paths = aggregate_paths
    end

    def dependencies
      aggregate_packages
    end

    def any_packages?
      finders.map do |finder|
        finder.prepare_projects if @config.prepare
        finder.any_packages?
      end.reduce(:|)
    end

    def unapproved
      aggregate_packages.reject(&:approved?)
    end

    def restricted
      aggregate_packages.select(&:restricted?)
    end

    private

    def finders
      return @finders unless @finders.nil?

      @finders = if @aggregate_paths.nil?
                   [LicenseFinder::Core.new(@config)]
                 else
                   @aggregate_paths.map do |path|
                     # Passing file paths as values instead of allowing them to evaluate in config
                     LicenseFinder::Core.new(@config.merge(project_path: path,
                                                           log_directory: @config.log_directory || @config.project_path,
                                                           decisions_file: @config.decisions_file_path))
                   end
                 end
    end

    def aggregate_packages
      return @packages unless @packages.nil?

      all_packages = finders.flat_map do |finder|
        finder.prepare_projects if @config.prepare
        finder.acknowledged.map { |dep| MergedPackage.new(dep, [finder.project_path]) }
      end
      @packages = all_packages.group_by { |package| [package.name, package.version] }
                              .map do |_, packages|
        MergedPackage.new(packages[0].dependency, packages.flat_map(&:aggregate_paths))
      end
    end
  end
end
