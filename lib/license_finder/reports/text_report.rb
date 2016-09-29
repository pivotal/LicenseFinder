module LicenseFinder
  class TextReport < CsvReport
    COMMA_SEP =  ", "

    def initialize(dependencies, options)
      empty_options = {}
      default_columns = %w[name version licenses]
      columns = (Array(options[:columns]) & self.class::AVAILABLE_COLUMNS) || default_columns
      super(dependencies, empty_options.merge(columns: columns))
    end
  end
end
