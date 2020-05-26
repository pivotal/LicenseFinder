# frozen_string_literal: true

require 'bundler'
require 'securerandom'

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

    def package_management_command
      'bundle'
    end

    def prepare_command
      ignored_groups_argument = !ignored_groups.empty? ? "--without #{ignored_groups.to_a.join(' ')}" : ''

      gem_path = "lf-bundler-gems-#{SecureRandom.uuid}"
      logger.info self.class, "Running bundle install for #{Dir.pwd} with path #{gem_path}", color: :blue

      "bundle install #{ignored_groups_argument} --path #{gem_path}".strip
    end

    def possible_package_paths
      [project_path.join(gemfile)]
    end

    private

    attr_reader :ignored_groups

    def definition
      ENV['BUNDLE_GEMFILE'] = "#{project_path}/#{gemfile}"

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

      # clear gem paths before running specs_for
      Gem.clear_paths
      if bundler_config_path_found
        ::Bundler.reset!
        ::Bundler.configure
      end
      @gem_details = definition.specs_for(included_groups)
    end

    def bundler_details
      @bundler_details ||= definition.dependencies
    end

    def included_groups
      definition.groups - ignored_groups.map(&:to_sym)
    end

    def lockfile_path
      project_path.join(lockfile)
    end

    def bundler_config_path_found
      config_file = project_path.join('.bundle/config')

      return false unless File.exist?(config_file)

      content = File.readlines(config_file)
      content.grep(/BUNDLE_PATH/).count.positive?
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

    def gemfile
      File.basename(ENV['BUNDLE_GEMFILE'] || 'Gemfile')
    end

    def lockfile
      "#{gemfile}.lock"
    end
  end
end
