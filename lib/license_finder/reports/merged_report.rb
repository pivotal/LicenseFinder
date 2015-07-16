module LicenseFinder
  class MergedReport < CsvReport
    def initialize(dependencies, options = {})
      super(dependencies, options.merge(columns: %w(name version licenses subproject_path)))
    end
  end
end