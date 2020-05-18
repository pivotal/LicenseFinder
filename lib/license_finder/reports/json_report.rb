require 'csv'

module LicenseFinder
  class JsonReport < CsvReport
    NEWLINE_SEP = "\n".freeze

    def initialize(dependencies, options)
      super(dependencies, options)
    end

    def to_s
      {dependencies: build_deps}.to_json
    end

    private

    def build_deps
      sorted_dependencies.map do |dep|
        @columns.inject({}) do |memo, column|
          memo[column] = send("format_#{column}", dep)
          memo
        end
      end
    end

    def format_licenses(dep)
      dep.missing? ? [] : dep.licenses.map(&:name)
    end
  end
end
