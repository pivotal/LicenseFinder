module LicenseFinder
  class YmlToSql
    def self.convert_if_required
      if needs_conversion?
        convert_all(load_yml)
        remove_yml
      end
    end

    def self.load_yml
      YAML.load yml_path.read
    end

    def self.convert_all(all_legacy_attrs)
      converters = all_legacy_attrs.map do |attrs|
        new(attrs)
      end
      converters.each(&:convert)
      converters.each(&:associate_children)
    end

    def self.needs_conversion?
      yml_path.exist?
    end

    def self.remove_yml
      yml_path.delete
    end

    def self.yml_path
      LicenseFinder.config.artifacts.legacy_yaml_file
    end

    def initialize(attrs)
      @legacy_attrs = attrs
    end

    attr_reader :legacy_attrs

    def convert
      @dep = create_dependency
      @dep.added_manually = manually_managed?
      add_approval
      associate_bundler_groups
      @dep.save
    end

    def associate_children
      find_children.each do |child|
        @dep.add_child(child)
      end
    end

    def associate_bundler_groups
      find_bundler_groups.each do |group|
        @dep.add_bundler_group(group)
      end
    end

    def manually_managed?
      legacy_attrs['source'] != "bundle"
    end

    def add_approval
      @dep.manual_approval = Sql::ManualApproval.new if legacy_attrs['approved']
    end

    def create_dependency
      Sql::Dependency.convert(legacy_attrs)
    end

    def find_children
      Sql::Dependency.where(name: legacy_attrs['children'])
    end

    def find_bundler_groups
      (legacy_attrs['bundler_groups'] || []).map do |name|
        Sql::BundlerGroup.find_or_create(name: name.to_s)
      end
    end

    module Sql
      class Dependency < Sequel::Model
        plugin :boolean_readers

        one_to_one :manual_approval
        many_to_many :children, join_table: :ancestries, left_key: :parent_dependency_id, right_key: :child_dependency_id, class: self
        many_to_many :bundler_groups

        VALID_ATTRIBUTES = {
          'name' => 'name',
          'version' => 'version',
          'summary' => 'summary',
          'description' => 'description',
          'homepage' => 'homepage',
          'license' => 'license_names'
        }

        def self.convert(attrs)
          create remap_attrs(attrs)
        end

        def self.remap_attrs(legacy_attrs)
          VALID_ATTRIBUTES.each_with_object({}) do |(legacy_key, new_key), new_attrs|
            new_attrs[new_key] = legacy_attrs[legacy_key]
          end
        end
      end

      class BundlerGroup < Sequel::Model
      end

      class ManualApproval < Sequel::Model
      end
    end
  end
end
