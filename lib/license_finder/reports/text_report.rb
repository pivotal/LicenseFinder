module LicenseFinder
  class TextReport < CsvReport
    COMMA_SEP =  ", "

    private

    def format_dependency(dep)
      [
        dep.name,
        dep.version,
        format_licenses(dep.licenses)
      ]
    end
  end
end
