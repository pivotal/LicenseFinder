# frozen_string_literal: true

require 'parallel'

module LicenseFinder
  class BundlerCLI < PackageManager
    def self.id
      'bundlercli'
    end

    def initialize(options = {})
      super
      @ignored_groups = options[:ignored_groups]
      @bundler_options = options[:bundler_options]
    end

    def current_packages
      bundle_list.map do |gem_spec|
        BundlerCLIPackage.new(gem_spec, logger: logger)
      end
    end

    def package_management_command
      'bundle'
    end

    def prepare_command
      "bundle install #{@bundler_options}"
    end

    def possible_package_paths
      [project_path.join(gemfile)]
    end

    def prepare
      prep_cmd = prepare_command
      _stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(prep_cmd) }

      return if status.success?

      log_errors stderr
      raise "Prepare command '#{prep_cmd}' failed" unless @prepare_no_fail
    end

    private

    attr_reader :ignored_groups

    def bundle_list
      ignored_groups_argument = ''
      ignored_groups_argument = " --without-group=#{ignored_groups.to_a.join(' ')}" unless ignored_groups.empty?

      list_cmd = "bundle list --name-only#{ignored_groups_argument} #{@bundler_options}"
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(list_cmd) }

      unless status.success?
        log_errors stderr
        raise "Failed running #{list_cmd}"
      end

      logger.debug self.class, 'Command: ' + list_cmd, color: :green

      deps = stdout
        .each_line
        .map(&:strip)

      threads = ::Parallel.processor_count

      Dir.chdir(project_path) do
        ::Parallel.map(deps, in_threads: threads) do |dep|
          logger.debug self.class, "Fetching gemspec: #{dep}", color: :green
          bundle_gem_spec(dep)
        end
      end
    end

    def bundle_gem_spec(dep)
      spec_cmd = "bundle exec gem spec --yaml #{dep}"
      stdout, stderr, status = Cmd.run(spec_cmd)

      unless status.success?
        log_errors stderr
        raise "Failed running #{spec_cmd} for #{dep}"
      end

      YAML.load(stdout)
    end

    def gemfile
      File.basename(ENV['BUNDLE_GEMFILE'] || 'Gemfile')
    end
  end
end
