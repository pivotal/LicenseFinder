module LicenseFinder
  class StatusReport < CsvReport
    def initialize(dependencies, options={})
      super(dependencies, options.merge(columns: %w[approved name version licenses]))
    end
  end
end
