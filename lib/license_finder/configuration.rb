# frozen_string_literal: true

require_relative 'platform'

module LicenseFinder
  class Configuration
    def self.with_optional_saved_config(primary_config)
      project_path = Pathname(primary_config.fetch(:project_path, Pathname.pwd)).expand_path
      config_file =  project_path.join('config', 'license_finder.yml')
      saved_config = config_file.exist? ? YAML.safe_load(config_file.read) : {}
      new(primary_config, saved_config)
    end

    def initialize(primary_config, saved_config)
      @primary_config = primary_config
      @saved_config = saved_config
    end

    def valid_project_path?
      return project_path.exist? if get(:project_path)

      true
    end

    def elixir_command
      get(:elixir_command) || 'elixir'
    end

    def mix_command
      get(:mix_command) || 'mix'
    end

    def merge(other_hash)
      dup_with other_hash
    end

    def rebar_deps_dir
      path = get(:rebar_deps_dir) || '_build/default/lib'
      project_path.join(path).expand_path
    end

    def mix_deps_dir
      path = get(:mix_deps_dir) || 'deps'
      project_path.join(path).expand_path
    end

    def decisions_file_path
      path = File.join(project_path, 'doc/dependency_decisions.yml') unless project_path.nil?
      path = get(:decisions_file) unless get(:decisions_file).nil?
      path = 'doc/dependency_decisions.yml' if path.nil?
      Pathname.new(path)
    end

    def log_directory
      path = get(:log_directory) || 'lf_logs'

      if (aggregate_paths || recursive) && project_path == ''
        Pathname(path).expand_path
      else
        project_path.join(path).expand_path
      end
    end

    def project_path
      Pathname(path_prefix).expand_path
    end

    def enabled_package_manager_ids
      get(:enabled_package_managers)
    end

    def logger_mode
      get(:logger)
    end

    def gradle_command
      get(:gradle_command)
    end

    def go_full_version
      get(:go_full_version)
    end

    def gradle_include_groups
      get(:gradle_include_groups)
    end

    def maven_include_groups
      get(:maven_include_groups)
    end

    def maven_options
      get(:maven_options)
    end

    def npm_options
      get(:npm_options)
    end

    def pip_requirements_path
      get(:pip_requirements_path)
    end

    def conda_bash_setup_script
      get(:conda_bash_setup_script)
    end

    def python_version
      get(:python_version)
    end

    def rebar_command
      get(:rebar_command)
    end

    def prepare
      get(:prepare) || prepare_no_fail
    end

    def prepare_no_fail
      get(:prepare_no_fail)
    end

    def write_headers
      get(:write_headers)
    end

    def save_file
      get(:save)
    end

    def aggregate_paths
      get(:aggregate_paths)
    end

    def recursive
      get(:recursive)
    end

    def format
      get(:format)
    end

    def columns
      get(:columns)
    end

    def sbt_include_groups
      get(:sbt_include_groups)
    end

    def composer_check_require_only
      get(:composer_check_require_only)
    end

    attr_writer :strict_matching

    attr_reader :strict_matching

    protected

    attr_accessor :primary_config
    def dup_with(other_hash)
      dup.tap do |dup|
        dup.primary_config.merge!(other_hash)
      end
    end

    private

    attr_reader :saved_config

    def get(key)
      @primary_config[key.to_sym] || @saved_config[key.to_s]
    end

    def initialize_copy(orig)
      super
      @primary_config = @primary_config.dup
    end

    def path_prefix
      get(:project_path) || ''
    end
  end
end
