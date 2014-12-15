require 'csv'

module LicenseFinder
  class TextReport < DependencyReport
    def to_s
      CSV.generate(col_sep: ", ") do |csv|
        missing_dependency_text = "This package is not installed. Please install to determine licenses."
        sorted_dependencies.each do |s|
            csv << [
                s.name,
                s.version,
                s.missing ? missing_dependency_text : s.licenses.map(&:name).join(', ')
            ]
        end
      end
    end
  end
end
