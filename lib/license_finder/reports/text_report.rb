module LicenseFinder
  class TextReport < CsvReport
    COMMA_SEP = ', '.freeze

    def initialize(dependencies, options = {})
      super(dependencies, options)

      default_columns = %w[name version licenses]
      @columns = default_columns if @columns.empty?
    end
  end
end
