module LicenseFinder
  class DiffReport < CsvReport
    def initialize(dependencies, options={})
      super(dependencies, options.merge(columns: %w[status name version licenses]))
    end
  end
end
