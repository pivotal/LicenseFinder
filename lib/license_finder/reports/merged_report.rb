module LicenseFinder
  class MergedReport < CsvReport
    AVAILABLE_COLUMNS = AVAILABLE_COLUMNS + ['subproject_paths']

    def initialize(dependencies, options = {})
      super(dependencies, options.merge(columns: %w(name version licenses subproject_paths)))
    end

    def format_subproject_paths(merged_dep)
      merged_dep.subproject_paths.join(self.class::COMMA_SEP)
    end
  end
end
