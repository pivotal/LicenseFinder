require "bundler"

module LicenseFinder
  class Bundler < PackageManager
    def initialize options={}
      super
      @ignored_groups = options[:ignored_groups]
      @definition    = options[:definition] # dependency injection for tests
    end

    def current_packages
      logger.log self.class, "including groups #{included_groups.inspect}"
      details.map do |gem_detail, bundle_detail|
        BundlerPackage.new(gem_detail, bundle_detail, logger: logger).tap do |package|
          logger.package self.class, package
        end
      end
    end

    def self.package_management_command
      "bundle"
    end

    private

    attr_reader :ignored_groups

    def definition
      if @definition.nil?
        ENV['BUNDLE_GEMFILE'] = package_path.to_s
        ::Bundler.setup
        @definition = ::Bundler::Definition.build(package_path, lockfile_path, nil)
      end
      @definition
    end

    def details
      gem_details.map do |gem_detail|
        bundle_detail = bundler_details.detect { |bundle_detail| bundle_detail.name == gem_detail.name }
        [gem_detail, bundle_detail]
      end
    end

    def gem_details
      @gem_details ||= definition.specs_for(included_groups)
    end

    def bundler_details
      @bundler_details ||= definition.dependencies
    end

    def included_groups
      definition.groups - ignored_groups.map(&:to_sym)
    end

    def package_path
      project_path.join("Gemfile")
    end

    def lockfile_path
      project_path.join('Gemfile.lock')
    end
  end
end
