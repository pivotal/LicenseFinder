module LicenseFinder
  class MergedReport < CsvReport
    AVAILABLE_COLUMNS = AVAILABLE_COLUMNS << 'subproject_path'

    def initialize(dependencies, options = {})
      super(dependencies, options.merge(columns: %w(name version licenses subproject_path)))
    end

    def format_subproject_path(merged_dep)
      merged_dep.subproject_path
    end
  end
end