module LicenseFinder
  class JsonReport < CsvReport
    def initialize(dependencies, options)
      options[:columns] ||= %w[name version licenses approved]
      super
      @columns = Array(options[:columns]) & self.class::AVAILABLE_COLUMNS
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
