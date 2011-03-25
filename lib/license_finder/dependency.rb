module LicenseFinder
  class Dependency

    attr_reader :name, :version, :license, :approved

    def self.from_yaml(yml)
      attrs = YAML.load(yml)
      new(attrs['name'], attrs['version'], attrs['license'], attrs['approved'])
    end

    def self.from_hash(attrs)
      new(attrs['name'], attrs['version'], attrs['license'], attrs['approved'])
    end

    def initialize(name, version, license, approved)
      @name = name
      @version = version
      @license = license
      @approved = approved
    end

    def to_yaml_entry
      "- name: \"#{name}\"\n  version: \"#{version}\"\n  license: \"#{license}\"\n  approved: #{approved}\n"
    end

  end
end

