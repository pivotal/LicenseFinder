module LicenseFinder
  class Dependency
    class Database
      def initialize
        @dependency_attributes = YAML.load File.read(LicenseFinder.config.dependencies_yaml) if File.exists?(LicenseFinder.config.dependencies_yaml)
      end

      def find(&block)
        dependency_attributes.detect &block
      end

      def update(dependency_hash)
        dependency_attributes.reject! { |a| a['name'] == dependency_hash['name'] }
        dependency_attributes << dependency_hash
        persist!
      end

      def delete_all
        File.delete(LicenseFinder.config.dependencies_yaml) if File.exists?(LicenseFinder.config.dependencies_yaml)
        @dependency_attributes = nil
      end

      def persist!
        File.write(LicenseFinder.config.dependencies_yaml, dependency_attributes.to_yaml)
      end

      private
      def dependency_attributes
        @dependency_attributes ||= []
      end
    end

    include Viewable

    ATTRIBUTE_NAMES = [
      "name", "source", "version", "license", "license_url", "approved", "notes",
      "license_files", "readme_files", "bundler_groups", "summary",
      "description", "homepage", "children", "parents"
    ]


    attr_accessor *ATTRIBUTE_NAMES

    attr_reader :summary, :description

    def self.from_hash(attrs)
      new(attrs)
    end

    def self.find_by_name(name)
      attributes = database.find { |a| a['name'] == name }
      new(attributes) if attributes
    end

    def self.database
      @database ||= Database.new
    end

    def initialize(attributes = {})
      update_attributes_without_saving attributes
    end

    def update_attributes new_values
      update_attributes_without_saving(new_values)
      save
    end



    def approved
      return @approved if defined?(@approved)

      @approved = LicenseFinder.config.whitelist.include?(license)
    end

    def notes
      @notes ||= ''
    end

    def license_files
      @license_files ||= []
    end

    def readme_files
      @readme_files ||= []
    end

    def bundler_groups
      @bundler_groups ||= []
    end

    def children
      @children ||= []
    end

    def parents
      @parents ||= []
    end

    def approve!
      @approved = true
      save
    end

    def save
      self.class.database.update(attributes)
    end

    def attributes
      attributes = {}

      ATTRIBUTE_NAMES.each do |attrib|
        attributes[attrib] = send attrib
      end

      attributes
    end

    def license_url
      LicenseFinder::LicenseUrl.find_by_name license
    end

    def merge(other)
      raise "Cannot merge dependencies with different names. Expected #{name}, was #{other.name}." unless other.name == name

      merged = self.class.new(other.attributes.merge('notes' => notes))

      case other.license
      when license, 'other'
        merged.license = license
        merged.approved = approved
      else
        merged.license = other.license
        merged.approved = other.approved
      end

      merged
    end

    def as_yaml
      attributes
    end

    def to_s
      [name, version, license].join ", "
    end

    private

    def update_attributes_without_saving(new_values)
      new_values.each do |key, value|
        send("#{key}=", value)
      end
    end

    def constantize(string)
      names = string.split('::')
      names.shift if names.empty? || names.first.empty?

      constant = Object
      names.each do |name|
        constant = constant.const_defined?(name, false) ? constant.const_get(name) : constant.const_missing(name)
      end
      constant
    end
  end
end

