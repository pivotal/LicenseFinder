# frozen_string_literal: true

module LicenseFinder
  class NpmPackage < Package
    attr_accessor :identifier, :dependencies, :groups, :json

    class << self
      def packages_from_json(npm_json, package_path)
        @packages = flattened_dependencies(npm_json)
        package_json = PackageJson.new(package_path)
        populate_groups(package_json)
        @packages.reject! do |_identifier, package|
          package.name.empty? &&
            package.version.empty? &&
            package.licenses.length == 1 &&
            package.licenses.first.name == 'unknown'
        end
        @packages.values
      end

      private

      def flattened_dependencies(npm_json, existing_packages = {})
        identifier = Identifier.from_hash npm_json
        if existing_packages[identifier].nil?
          existing_packages[identifier] = NpmPackage.new(npm_json) if identifier
          npm_json.fetch('dependencies', {}).values.map do |d|
            flattened_dependencies(d, existing_packages)
          end
        else
          duplicate_package = NpmPackage.new(npm_json)
          unless existing_packages[identifier].dependencies.include?(duplicate_package.dependencies)
            existing_packages[identifier].dependencies |= duplicate_package.dependencies
            npm_json.fetch('dependencies', {}).values.map do |d|
              flattened_dependencies(d, existing_packages)
            end
          end
        end
        existing_packages
      end

      def populate_groups(package_json)
        package_json.groups.each do |group|
          group.package_names.each do |package_name|
            @packages.each_key do |identifier|
              next unless identifier.name == package_name

              dependency = @packages[identifier]
              dependency.groups |= [group.name]
              populate_child_groups(dependency, @packages)
            end
          end
        end
      end

      def populate_child_groups(dependency, packages, populated_ids = [])
        dependency.dependencies.each do |id|
          next if populated_ids.include? id

          populated_ids.push id
          packages[id].groups |= dependency.groups
          populate_child_groups(packages[id], packages, populated_ids)
        end
      end
    end

    def initialize(npm_json)
      @json = npm_json
      @identifier = Identifier.from_hash(npm_json)
      @dependencies = deps_from_json
      super(@identifier.name,
            @identifier.version,
            description: npm_json['description'],
            homepage: npm_json['homepage'],
            spec_licenses: Package.license_names_from_standard_spec(npm_json),
            install_path: npm_json['path'],
            children: @dependencies.map(&:name))
    end

    def ==(other)
      other.is_a?(NpmPackage) && @identifier == other.identifier
    end

    def to_s
      @identifier.to_s
    end

    def package_manager
      'Npm'
    end

    def package_url
      "https://www.npmjs.com/package/#{CGI.escape(name)}/v/#{CGI.escape(version)}"
    end

    private

    def deps_from_json
      @json.fetch('dependencies', {}).values.map { |dep| Identifier.from_hash(dep) }.compact
    end

    class Identifier
      attr_accessor :name, :version

      def initialize(name, version)
        @name = name
        @version = version
      end

      def self.from_hash(hash)
        name = hash['name']
        version = hash['version']
        return nil if name.nil? || version.nil?

        Identifier.new(name, version)
      end

      def ==(other)
        other.is_a?(Identifier) && @name == other.name && @version == other.version
      end

      def eql?(other)
        self == other
      end

      def hash
        [@name, @version].hash
      end

      def <=>(other)
        sort_name = @name <=> other.name
        sort_name.zero? ? @version <=> other.version : sort_name
      end

      def to_s
        "#{@name} - #{@version}"
      end
    end

    class Group
      attr_accessor :name, :package_names

      def initialize(name, hash)
        @name = name
        @package_names = hash.keys
      end

      def include?(identifier)
        @package_names.include? identifier.name
      end

      def to_s
        @name
      end
    end

    class PackageJson
      attr_reader :groups
      DEPENDENCY_GROUPS = %w[dependencies devDependencies].freeze

      def initialize(path)
        json = JSON.parse(File.read(path), max_nesting: false)
        @groups = DEPENDENCY_GROUPS.map { |name| Group.new(name, json.fetch(name, {})) }
      end

      def groups_for(identifier)
        @groups.select { |g| g.include? identifier }.map(&:name)
      end
    end
  end
end
