# frozen_string_literal: true

require 'bundler'
require 'securerandom'
require 'shellwords'

module LicenseFinder
  class Bundler < PackageManager
    def initialize(options = {})
      super
      @ignored_groups = options[:ignored_groups]
      @gemfiles = Array(options[:bundler_gemfiles]) unless options[:bundler_gemfiles].nil?
      @definition = options[:definition] # dependency injection for tests
    end

    def current_packages
      packages = existing_gemfile_paths.flat_map { |gemfile_path| current_packages_for(gemfile_path) }

      packages.group_by { |package| [package.name, package.version] }.map do |_, same_packages|
        merge_groups(same_packages)
      end
    end

    def package_management_command
      'bundle'
    end

    def prepare_command
      ignored_groups_argument = !ignored_groups.empty? ? "--without #{ignored_groups.to_a.join(' ')}" : ''

      gem_path = "lf-bundler-gems-#{SecureRandom.uuid}"
      logger.info self.class, "Running bundle install for #{Dir.pwd} with path #{gem_path}", color: :blue

      return "bundle install #{ignored_groups_argument} --path #{gem_path}".strip if existing_gemfile_paths.size <= 1

      existing_gemfile_paths.map do |gemfile_path|
        gemfile_argument = "--gemfile #{Shellwords.escape(relative_to_project(gemfile_path))}"
        "bundle install #{gemfile_argument} #{ignored_groups_argument} --path #{gem_path}".squeeze(' ')
      end.join(' && ')
    end

    def possible_package_paths
      gemfile_paths
    end

    private

    attr_reader :ignored_groups

    def current_packages_for(gemfile_path)
      with_gemfile(gemfile_path) do
        definition = definition_for(gemfile_path)
        included_groups = definition.groups - ignored_groups.map(&:to_sym)
        logger.debug self.class, "including groups #{included_groups.inspect} from #{gemfile_path}"

        details(definition, included_groups, gemfile_path).map do |gem_detail, bundle_detail|
          BundlerPackage.new(gem_detail, bundle_detail, logger: logger).tap do |package|
            log_package_dependencies package
          end
        end
      end
    end

    def definition_for(gemfile_path)
      @definition || ::Bundler::Definition.build(gemfile_path, lockfile_path(gemfile_path), nil)
    end

    def details(definition, included_groups, gemfile_path)
      bundler_details = definition.dependencies

      gem_details(definition, included_groups, gemfile_path).map do |gem_detail|
        bundle_detail = bundler_details.detect { |bundler_detail| bundler_detail.name == gem_detail.name }
        [gem_detail, bundle_detail]
      end
    end

    def gem_details(definition, included_groups, gemfile_path)
      # clear gem paths before running specs_for
      Gem.clear_paths
      if bundler_config_path_found(gemfile_path)
        ::Bundler.reset!
        ::Bundler.configure
      end
      definition.specs_for(included_groups)
    end

    # The same gem (name and version) may be locked by several gemfiles,
    # in which case it should be reported once, but under all its groups.
    def merge_groups(packages)
      packages.first.tap do |package|
        package.groups.concat(packages.drop(1).flat_map(&:groups)).uniq!
      end
    end

    def with_gemfile(gemfile_path)
      previous_gemfile = ENV['BUNDLE_GEMFILE']
      ENV['BUNDLE_GEMFILE'] = gemfile_path.to_s
      yield
    ensure
      ENV['BUNDLE_GEMFILE'] = previous_gemfile
    end

    def lockfile_path(gemfile_path)
      Pathname("#{gemfile_path}.lock")
    end

    # Bundler keeps the config (e.g. BUNDLE_PATH for vendored gems) next to the gemfile
    def bundler_config_path_found(gemfile_path)
      config_file = gemfile_path.dirname.join('.bundle/config')

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

    # All the gemfiles to be scanned, from the `bundler_gemfiles` option
    # (which accepts glob patterns, e.g. `gemfiles/*.gemfile` for Appraisal),
    # or the one in BUNDLE_GEMFILE, or `Gemfile`, relative to the project path.
    def gemfile_paths
      @gemfile_paths ||= gemfiles.flat_map { |gemfile| expand_gemfile(gemfile) }.uniq
    end

    def existing_gemfile_paths
      gemfile_paths.select(&:exist?)
    end

    def gemfiles
      @gemfiles || [default_gemfile]
    end

    def relative_to_project(gemfile_path)
      gemfile_path.expand_path.relative_path_from(project_path.expand_path).to_s
    end

    def expand_gemfile(gemfile)
      return [project_path.join(gemfile)] unless glob?(gemfile)

      Dir.glob(gemfile, base: project_path.to_s).sort
         .reject { |path| path.end_with?('.lock') }
         .map { |path| project_path.join(path) }
    end

    def glob?(gemfile)
      gemfile.match?(/[*?\[{]/)
    end

    # BUNDLE_GEMFILE is taken as relative to the project path. Through `bundle exec`
    # it gets expanded to an absolute path, which may point to another project
    # (e.g. when using --project_path), in which case only its basename is kept.
    def default_gemfile
      gemfile = ENV['BUNDLE_GEMFILE']
      return 'Gemfile' if gemfile.nil? || gemfile.empty?
      return gemfile unless Pathname(gemfile).absolute?

      gemfile = Pathname(gemfile).expand_path
      project_root = project_path.expand_path
      gemfile.ascend.any? { |path| path == project_root } ? gemfile.to_s : gemfile.basename.to_s
    end
  end
end
