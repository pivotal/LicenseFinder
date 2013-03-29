require 'sequel'

DB = Sequel.connect("sqlite://#{LicenseFinder.config.database_path}")
Sequel.extension :migration, :core_extensions
Sequel::Migrator.run(DB, LicenseFinder::ROOT_PATH.join('../db/migrate'))

module LicenseFinder
  class YmlToSql
    def self.convert_all(all_legacy_attrs)
      converters = all_legacy_attrs.map do |attrs|
        new(attrs)
      end
      converters.each(&:convert)
      converters.each(&:associate_children)
    end

    def self.needs_conversion?
      File.exists?(LicenseFinder.config.dependencies_yaml)
    end

    def self.remove_yml
      File.delete(LicenseFinder.config.dependencies_yaml)
    end

    def initialize(attrs)
      @legacy_attrs = attrs
    end

    attr_reader :legacy_attrs

    def convert
      @dep = create_dependency
      @dep.license = create_license
      @dep.approval = create_approval
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

    def create_dependency
      Sql::Dependency.convert(legacy_attrs)
    end

    def create_license
      Sql::License.convert(legacy_attrs)
    end

    def create_approval
      Sql::Approval.convert(legacy_attrs)
    end

    def find_children
      Sql::Dependency.where(name: legacy_attrs['children'])
    end

    def find_bundler_groups
      (legacy_attrs['bundler_groups'] || []).map do |name|
        Sql::BundlerGroup.find_or_create(name: name)
      end
    end

    module Sql
      module Convertable
        def convert(attrs)
          create remap_attrs(attrs)
        end

        def remap_attrs(legacy_attrs)
          self::VALID_ATTRIBUTES.each_with_object({}) do |(legacy_key, new_key), new_attrs|
            new_attrs[new_key] = legacy_attrs[legacy_key]
          end
        end
      end

      class Dependency < Sequel::Model
        extend Convertable
        VALID_ATTRIBUTES = Hash[*%w[name version summary description homepage].map { |k| [k, k] }.flatten]

        many_to_one :license
        many_to_one :approval
        many_to_many :children, join_table: :ancestries, left_key: :parent_dependency_id, right_key: :child_dependency_id, class: self
        many_to_many :bundler_groups
      end

      class BundlerGroup < Sequel::Model
      end

      class License < Sequel::Model
        extend Convertable

        VALID_ATTRIBUTES = {
          'license' => 'name',
          'license_url' => 'url',
          'manual' => 'manual'
        }
      end

      class Approval < Sequel::Model
        extend Convertable

        VALID_ATTRIBUTES = {
          'approved' => 'state'
        }
      end
    end
  end
end
