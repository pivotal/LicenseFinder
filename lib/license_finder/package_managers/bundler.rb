require "bundler"

module LicenseFinder
  class Bundler < PackageManager
    def initialize options={}
      super
      @definition = options[:definition] # dependency injection for tests
    end

    def current_packages
      definition.specs.map do |gem_def|
        bundler_def = bundler_defs.detect { |bundler_def| bundler_def.name == gem_def.name }
        BundlerPackage.new(gem_def, bundler_def, logger: logger).tap do |package|
          logger.package self.class, package
        end
      end
    end

    private

    def definition
      # DI
      @definition ||= ::Bundler::Definition.build(package_path, lockfile_path, nil)
    end

    def package_path
      project_path.join("Gemfile")
    end

    def bundler_defs
      # memoized
      @bundler_defs ||= definition.dependencies
    end

    def lockfile_path
      package_path.dirname.join('Gemfile.lock')
    end
  end
end
