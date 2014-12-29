module LicenseFinder
  class DetailedTextReport < CsvReport
    def initialize(dependencies, options={})
      super(dependencies, options.merge(columns: %w[name version licenses summary description]))
    end
  end
end
