module LicenseFinder
  class DetailedTextReport < CsvReport
    private

    def format_dependency(dep)
      [
        dep.name,
        dep.version,
        format_licenses(dep.licenses),
        dep.summary ? dep.summary.strip : "",
        dep.description ? dep.description.strip : ""
      ]
    end
  end
end
