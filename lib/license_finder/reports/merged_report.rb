module LicenseFinder
  class MergedReport < CsvReport
    AVAILABLE_COLUMNS = AVAILABLE_COLUMNS + ['aggregate_paths']

    def initialize(dependencies, options = {})
      options=options.dup
      options[:columns] ||= %w[name version licenses aggregate_paths]

      super(dependencies, options)
    end

    def format_aggregate_paths(merged_dep)
      merged_dep.aggregate_paths.join(self.class::COMMA_SEP)
    end
  end
end
