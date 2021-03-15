# frozen_string_literal: true

module LicenseFinder
  class CondaPackage < Package
    attr_accessor :identifier, :json

    def initialize(conda_json)
      @json = conda_json
      @identifier = Identifier.from_hash(conda_json)
      super(@identifier.name,
            @identifier.version,
            spec_licenses: Package.license_names_from_standard_spec(conda_json),
            children: children)
    end

    def ==(other)
      other.is_a?(CondaPackage) && @identifier == other.identifier
    end

    def to_s
      @identifier.to_s
    end

    def package_manager
      'Conda'
    end

    def package_url
      @json['url']
    end

    def children
      @json.fetch('depends', []).map { |constraint| constraint.split.first }
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
  end
end
