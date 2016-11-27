module LicenseFinder
  class TextReport < CsvReport
    COMMA_SEP =  ", "

    def initialize(dependencies, options={})
      super(dependencies, options)

      default_columns = %w[name version licenses]
      if @columns.empty?
        @columns = default_columns
      end
    end
  end
end
