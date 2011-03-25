module LicenseFinder
  class DependencyList

    attr_reader :dependencies
    def self.from_bundler
      new(Bundler.load.specs.map { |spec| GemSpecDetails.new(spec).dependency })
    end

    def initialize(dependencies)
      @dependencies = dependencies
    end

    def self.from_yaml(yml)
      deps = YAML.load(yml)
      new(deps.map{|dhash| Dependency.from_hash(dhash)})
    end

    def to_yaml
      result = "--- \n"
      dependencies.inject(result) {|r, d| r << d.to_yaml_entry; r}
    end
  end
end

