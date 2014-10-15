require 'csv'

module LicenseFinder
  class DetailedTextReport < DependencyReport
    def to_s
      CSV.generate(col_sep: ",") do |csv|
        sorted_dependencies.each do |s|
          csv << [
            s.name,
            s.version,
            s.licenses.map(&:name).join(','),
            s.summary ? s.summary.strip : "",
            s.description ? s.description.strip : ""
          ]
        end
      end
    end
  end
end
