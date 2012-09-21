module LicenseFinder
  module Persistence
    class Dependency
      class Database
        def initialize
          @dependency_attributes = YAML.load File.read(LicenseFinder.config.dependencies_yaml) if File.exists?(LicenseFinder.config.dependencies_yaml)
        end

        def find(&block)
          dependency_attributes.detect &block
        end

        def update(dependency_hash)
          destroy_by_name_without_saving dependency_hash['name']
          dependency_attributes << dependency_hash
          persist!
        end

        def delete_all
          File.delete(LicenseFinder.config.dependencies_yaml) if File.exists?(LicenseFinder.config.dependencies_yaml)
          @dependency_attributes = nil
        end

        def destroy_by_name(name)
          destroy_by_name_without_saving name
          persist!
        end

        def persist!
          File.open(LicenseFinder.config.dependencies_yaml, 'w+') do |f|
            f.write dependency_attributes.to_yaml
          end
        end

        def all
          dependency_attributes
        end

        private
        def destroy_by_name_without_saving(name)
          dependency_attributes.reject! { |a| a['name'] == name }
        end

        def dependency_attributes
          @dependency_attributes ||= []
        end
      end

      attr_accessor *LicenseFinder::DEPENDENCY_ATTRIBUTES

      class << self
        def find_by_name(name)
          attributes = database.find { |a| a['name'] == name }
          new(attributes) if attributes
        end

        def delete_all
          database.delete_all
        end

        def all
          database.all.map { |attributes| new(attributes) }
        end

        def unapproved
          all.select {|d| d.approved == false }
        end

        def update(attributes)
          database.update attributes
        end

        def destroy_by_name(name)
          database.destroy_by_name name
        end

        private
        def database
          @database ||= Database.new
        end
      end

      def initialize(attributes = {})
        update_attributes_without_saving attributes
      end

      def update_attributes new_values
        update_attributes_without_saving(new_values)
        save
      end

      def save
        self.class.update(attributes)
      end

      def destroy
        self.class.destroy_by_name(name)
      end

      def attributes
        attributes = {}

        LicenseFinder::DEPENDENCY_ATTRIBUTES.each do |attrib|
          attributes[attrib] = send attrib
        end

        attributes
      end

      private
      def update_attributes_without_saving(new_values)
        new_values.each do |key, value|
          send("#{key}=", value)
        end
      end
    end
  end
end

