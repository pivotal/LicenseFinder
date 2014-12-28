module LicenseFinder
  class StatusReport < CsvReport
    private

    def format_dependency(dep)
      [
        dep.approved? ? "X" : nil,
        dep.name,
        dep.version,
        format_licenses(dep.licenses)
      ]
    end
  end
end
