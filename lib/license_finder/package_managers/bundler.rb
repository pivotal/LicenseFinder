require "bundler"

module LicenseFinder
  class Bundler < PackageManager
    def initialize options={}
      super
      @definition = options[:definition] # dependency injection for tests
    end

    def current_packages
      details.map do |gem_detail, bundler_detail|
        BundlerPackage.new(gem_detail, bundler_detail, logger: logger).tap do |package|
          logger.package self.class, package
        end
      end
    end

    private

    def definition
      # DI
      @definition ||= ::Bundler::Definition.build(package_path, lockfile_path, nil)
    end

    def bundler_details
      @bundler_details ||= definition.dependencies
    end

    def gem_details
      @gem_details ||= definition.specs
    end

    def details
      gem_details.map do |gem_detail|
        bundler_detail = bundler_details.detect { |bundler_detail| bundler_detail.name == gem_detail.name }
        [gem_detail, bundler_detail]
      end
    end

    def package_path
      project_path.join("Gemfile")
    end

    def lockfile_path
      project_path.join('Gemfile.lock')
    end
  end
end
