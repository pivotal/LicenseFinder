module LicenseFinder
  class JsonReport < CsvReport
    def initialize(dependencies, options)
      super
    end

    def to_s
      {dependencies: build_deps}.to_json
    end

    def build_deps
      sorted_dependencies.map do |dep|
        columns.inject({}) do |memo, column|
          memo[column] = send("format_#{column}", dep)
          memo
        end
      end
    end

    private

    attr_reader :columns
  end
end
