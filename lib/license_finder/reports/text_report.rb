module LicenseFinder
  class TextReport < CsvReport
    COMMA_SEP =  ", "

    def initialize(dependencies, options={})
      super(dependencies, options.merge(columns: %w[name version licenses]))
    end
  end
end
