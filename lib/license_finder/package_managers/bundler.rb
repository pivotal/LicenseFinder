require 'bundler'

module LicenseFinder
  class Bundler < PackageManager
    def initialize(options = {})
      super
      @ignored_groups = options[:ignored_groups]
      @definition = options[:definition] # dependency injection for tests
    end

    def current_packages
      logger.debug self.class, "including groups #{included_groups.inspect}"
      details.map do |gem_detail, bundle_detail|
        BundlerPackage.new(gem_detail, bundle_detail, logger: logger).tap do |package|
          log_package_dependencies package
        end
      end
    end

    def self.package_management_command
      'bundle'
    end

    def self.prepare_command
      'bundle install'
    end

    def possible_package_paths
      [project_path.join('Gemfile')]
    end

    private

    attr_reader :ignored_groups

    def definition
      # DI
      @definition ||= ::Bundler::Definition.build(detected_package_path, lockfile_path, nil)
    end

    def details
      gem_details.map do |gem_detail|
        bundle_detail = bundler_details.detect { |bundler_detail| bundler_detail.name == gem_detail.name }
        [gem_detail, bundle_detail]
      end
    end

    def gem_details
      return @gem_details if @gem_details
      # clear gem paths before runninng specs_for
      Gem.clear_paths
      @gem_details = definition.specs_for(included_groups)
    end

    def bundler_details
      @bundler_details ||= definition.dependencies
    end

    def included_groups
      definition.groups - ignored_groups.map(&:to_sym)
    end

    def lockfile_path
      project_path.join('Gemfile.lock')
    end

    def log_package_dependencies(package)
      dependencies = package.children
      if dependencies.empty?
        logger.debug self.class, format("package '%s' has no dependencies", package.name)
      else
        logger.debug self.class, format("package '%s' has dependencies:", package.name)
        dependencies.each do |dep|
          logger.debug self.class, format('- %s', dep)
        end
      end
    end
  end
end
