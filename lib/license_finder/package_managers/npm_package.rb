module LicenseFinder
  class NpmPackage < Package
    attr_accessor :identifier, :dependencies, :groups

    def self.packages_from_json(npm_json, package_path)
      root_package = NpmPackage.new(npm_json).decircularize
      package_json = PackageJson.new(package_path)
      root_package.dependencies.each { |d| d.groups = package_json.groups(d.identifier) }
      root_package.propagate_groups
      root_package.dependencies.map(&:flatten).flatten.uniq(&:identifier)
    end

    def initialize(npm_json, root=self)
      @identifier = Identifier.from_hash(npm_json)
      @root = root
      @dependencies = npm_json.fetch('dependencies', {}).values.map { |d| NpmPackage.new(d, root) }
      super(@identifier.name,
            @identifier.version,
            description: npm_json['description'],
            homepage: npm_json['homepage'],
            spec_licenses: Package.license_names_from_standard_spec(npm_json),
            install_path: npm_json['path'],
            children: @dependencies.map(&:name))
    end

    def propagate_groups
      @dependencies.each do |child|
        child.groups = (child.groups + @groups).uniq
        child.propagate_groups
      end
      self
    end

    def decircularize
      noncircular = @root.find_noncircular(@identifier)
      noncircular.dependencies = @dependencies.map(&:decircularize)
      noncircular
    end

    def flatten
      [self] + @dependencies.map(&:flatten).flatten(1)
    end

    def find_noncircular(identifier)
      flatten.select{ |p| p.identifier == identifier }.find(&:noncircular?)
    end

    def noncircular?
      @licenses != ['[Circular]']
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

    class Identifier
      attr_accessor :name, :version

      def initialize(name, version)
        @name = name
        @version = version
      end

      def self.from_hash(hash)
        Identifier.new(hash['name'], hash['version'])
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
      attr_accessor :name, :package_identifiers

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
      DEPENDENCY_GROUPS = %w(dependencies devDependencies)

      def initialize(path)
        json = JSON.parse(File.read(path), max_nesting: false)
        @groups = DEPENDENCY_GROUPS.map { |name| Group.new(name, json.fetch(name, {})) }
      end

      def groups(identifier)
        @groups.select { |g| g.include? identifier }.map(&:name)
      end

    end
  end
end
