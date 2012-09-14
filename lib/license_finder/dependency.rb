# encoding: UTF-8
require "erb"

module LicenseFinder
  class Dependency
    include Viewable

    attr_accessor :name, :version, :license, :approved, :license_url, :notes, :license_files,
      :readme_files, :source, :bundler_groups, :homepage, :children, :parents

    attr_reader :summary, :description

    def self.from_hash(attrs)
      attrs['license_files'] = attrs['license_files'].map { |lf| lf['path'] } if attrs['license_files']
      attrs['readme_files'] = attrs['readme_files'].map { |rf| rf['path'] } if attrs['readme_files']

      new(attrs)
    end

    def initialize(attributes = {})
      @source = attributes['source']
      @name = attributes['name']
      @version = attributes['version']
      @license = attributes['license']
      @approved = attributes['approved'] || LicenseFinder.config.whitelist.include?(attributes['license'])
      @notes = attributes['notes'] || ''
      @license_files = attributes['license_files'] || []
      @readme_files = attributes['readme_files'] || []
      @bundler_groups = attributes['bundler_groups'] || []
      @summary = attributes['summary']
      @description = attributes['description']
      @homepage = attributes['homepage']
      @children = attributes.fetch('children', [])
      @parents = attributes.fetch('parents', [])
    end

    def license_url
      LicenseFinder::LicenseUrl.find_by_name license
    end

    def merge(other)
      raise "Cannot merge dependencies with different names. Expected #{name}, was #{other.name}." unless other.name == name

      merged = self.class.new(
        'name' => name,
        'version' => other.version,
        'license_files' => other.license_files,
        'readme_files' => other.readme_files,
        'license_url' => other.license_url,
        'notes' => notes,
        'source' => other.source,
        'summary' => other.summary,
        'description' => other.description,
        'bundler_groups' => other.bundler_groups,
        'homepage' => other.homepage,
        'children' => other.children,
        'parents' => other.parents
      )

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
      attrs = {
        'name' => name,
        'version' => version,
        'license' => license,
        'approved' => approved,
        'source' => source,
        'license_url' => license_url,
        'homepage' => homepage,
        'notes' => notes,
        'license_files' => nil,
        'readme_files' => nil
      }

      unless license_files.empty?
        attrs['license_files'] = license_files.map do |file|
          {'path' => file}
        end
      end

      unless readme_files.empty?
        attrs['readme_files'] = readme_files.map do |file|
          {'path' => file}
        end
      end

      attrs
    end

    def to_s
      [name, version, license].join ", "
    end

    private

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

