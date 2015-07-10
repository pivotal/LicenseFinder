module LicenseFinder
  class DiffReport < CsvReport
    def initialize(dependencies, options={})
      super(dependencies, options.merge(columns: %w[status name current_version previous_version licenses]))
    end
  end
end
