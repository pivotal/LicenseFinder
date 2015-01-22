module LicenseFinder
  class Configuration
    def self.with_optional_saved_config(primary_config, project_path)
      config_file = project_path.join('config', 'license_finder.yml')
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

    def decisions_file
      file_name = get(:decisions_file) || "doc/dependency_decisions.yml"
      Pathname(file_name)
    end

    private

    def get(key)
      @primary_config[key.to_sym] || @saved_config[key.to_s]
    end
  end
end
