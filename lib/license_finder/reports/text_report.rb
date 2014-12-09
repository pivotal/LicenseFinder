require 'csv'

module LicenseFinder
  class TextReport < DependencyReport
    def to_s
      CSV.generate(col_sep: ", ") do |csv|
        sorted_dependencies.each do |s|
          csv << [
            s.name,
            s.version,
            s.licenses.map(&:name).join(', ')
          ]
        end
      end
    end
  end
end
