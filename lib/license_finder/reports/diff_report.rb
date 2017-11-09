module LicenseFinder
  class DiffReport < CsvReport
    AVAILABLE_COLUMNS = AVAILABLE_COLUMNS + %w[status current_version previous_version project_paths]

    def initialize(dependencies, options = {})
      super(dependencies, options.merge(columns: build_columns(dependencies)))
    end

    def format_status(dep)
      dep.status
    end

    def format_version(dep)
      dep.version
    end

    def format_project_paths(dep)
      dep.aggregate_paths.join(self.class::COMMA_SEP)
    end

    private

    def build_columns(dependencies)
      columns = %w[status name version licenses]
      columns << 'project_paths' if dependencies.all?(&:merged_package?)
      columns
    end
  end
end
