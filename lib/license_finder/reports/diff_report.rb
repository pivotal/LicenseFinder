module LicenseFinder
  class DiffReport < CsvReport
    AVAILABLE_COLUMNS = AVAILABLE_COLUMNS + %w[status current_version previous_version project_paths]

    def initialize(dependencies, options={})
      super(dependencies, options.merge(columns: build_columns(dependencies)))
    end

    def format_status(dep)
      dep.status
    end

    def format_current_version(dep)
      dep.current_version
    end

    def format_previous_version(dep)
      dep.previous_version
    end

    def format_project_paths(dep)
      dep.subproject_paths.join(self.class::COMMA_SEP)
    end

    private

    def build_columns(dependencies)
      columns = %w[status name current_version previous_version licenses]
      columns << 'project_paths' if dependencies.all? { |delta| delta.merged_package? }
      columns
    end
  end
end
