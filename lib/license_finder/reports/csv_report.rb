require 'csv'

module LicenseFinder
  class CsvReport < Report
    COMMA_SEP =  ","

    def to_s
      CSV.generate(col_sep: self.class::COMMA_SEP) do |csv|
        sorted_dependencies.each do |s|
          csv << format_dependency(s)
        end
      end
    end

    private

    def format_licenses(licenses)
      licenses.map(&:name).join(self.class::COMMA_SEP)
    end
  end
end
