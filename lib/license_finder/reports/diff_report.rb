module LicenseFinder
  class DiffReport < CsvReport
    AVAILABLE_COLUMNS = AVAILABLE_COLUMNS + %w[status current_version previous_version]

    def initialize(dependencies, options={})
      super(dependencies, options.merge(columns: %w[status name current_version previous_version licenses]))
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
  end
end
