module LicenseFinder
  class Configuration
    def self.with_optional_saved_config(primary_config)
      project_path = Pathname(primary_config.fetch(:project_path, Pathname.pwd))
      config_file =  project_path.join('config', 'license_finder.yml')
      saved_config = config_file.exist? ? YAML.load(config_file.read) : {}
      new(primary_config, saved_config)
    end

    def initialize(primary_config, saved_config)
      @primary_config = primary_config
      @saved_config = saved_config
    end

    def gradle_command
      get(:gradle_command) || "gradle"
    end

    def rebar_command
      get(:rebar_command) || "rebar"
    end

    def rebar_deps_dir
      if get(:rebar_deps_dir)
        path_prefix + get(:rebar_deps_dir)
      else
        path_prefix + "deps"
      end
    end

    def decisions_file_path
      if get(:decisions_file)
        file_name = path_prefix + get(:decisions_file)
      else
        file_name = path_prefix + "doc/dependency_decisions.yml"
      end
      Pathname(file_name)
    end

    def project_path
      Pathname.pwd + Pathname(path_prefix)
    end

    private
    attr_reader :saved_config
    def get(key)
      @primary_config[key.to_sym] || @saved_config[key.to_s]
    end

    def path_prefix
      if get(:project_path)
        get(:project_path) + "/"
      else
        ""
      end
    end
  end
end
