# frozen_string_literal: true

require 'json'
require 'pathname'
require 'bundler'

module LicenseFinder
  class Bundler < PackageManager
    GroupDefinition = Struct.new(:groups)

    def initialize(options = {})
      super
      @ignored_groups = options[:ignored_groups]
    end

    def current_packages
      bundle_detail, gem_details = bundle_specs

      logger.debug self.class, "Bundler groups: #{bundle_detail.groups.inspect}", color: :green
      logger.debug self.class, "Ignored groups: #{ignored_groups.to_a.inspect}", color: :green

      gem_details.map do |gem_detail|
        BundlerPackage.new(gem_detail, bundle_detail, logger: logger).tap do |package|
          log_package_dependencies package
        end
      end
    end

    def package_management_command
      'bundle'
    end

    def prepare_command
      'bundle install'
    end

    def possible_package_paths
      [gemfile_path]
    end

    private

    attr_reader :ignored_groups

    def lf_bundler_exec
      lfs = Gem::Specification.find_by_name('license_finder')
      lfs.bin_file('license_finder_bundler')
    end

    def bundle_specs
      gemfile = gemfile_path.to_s
      result = ''

      Dir.chdir(project_path) do
        begin
          pread, pwrite = IO.pipe
          env = env_to_hash(ENV)
          env = reset_bundle_env(env)
          env['BUNDLE_GEMFILE'] = gemfile
          pid = spawn(env, lf_bundler_exec.to_s, *ignored_groups, out: pwrite)

          pwrite.close
          result = pread.read
          _pid, status = Process.wait2(pid)
          exit_status = status.exitstatus

          raise 'Unable to retrieve bundler gem specs' if exit_status != 0
          raise 'Unable to read bundler gem specs' if result.empty?
        ensure
          pwrite.close unless pwrite.closed?
          pread.close unless pread.closed?
        end
      end

      lf_bundler_def = JSON.parse(result)

      bundle_detail = GroupDefinition.new(lf_bundler_def['groups'])
      yaml_specs = lf_bundler_def['specs'].map { |gem_yaml| Gem::Specification.from_yaml(gem_yaml) }

      [bundle_detail, yaml_specs]
    end

    def gemfile_path
      return Pathname.new(project_path).join('Gemfile').expand_path unless ENV.key?('BUNDLE_GEMFILE')

      gemfile_relative_path = ENV.fetch('BUNDLE_GEMFILE')
      Pathname.new(gemfile_relative_path).expand_path
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

    def env_to_hash(env)
      to_hash = env.to_hash
      return to_hash unless Gem.win_platform?

      to_hash.each_with_object({}) {|(k,v), a| a[k.upcase] = v }
    end

    def reset_bundle_env(env_hash)
      env = env_hash.dup

      env_hash.each do |key, value|
        if key.start_with?(::Bundler::EnvironmentPreserver::BUNDLER_PREFIX)
          real_key = key[::Bundler::EnvironmentPreserver::BUNDLER_PREFIX.size..-1]
          env[real_key] = env[key]
          env[key] = nil
          env[real_key] = nil if env[real_key] == ::Bundler::EnvironmentPreserver::INTENTIONALLY_NIL
        end
      end

      env
    end
  end
end
