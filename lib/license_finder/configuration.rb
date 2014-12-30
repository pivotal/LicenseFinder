module LicenseFinder
  class Configuration
    def self.with_optional_saved_config(primary_config, project_path = Pathname.new('.'))
      config_file = project_path.join('config', 'license_finder.yml')
      saved_config = config_file.exist? ? YAML.load(config_file.read) : {}
      new(primary_config, saved_config)
    end

    def initialize(primary_config, saved_config)
      @primary_config = primary_config
      @saved_config = saved_config
    end

    def gradle_command
      @primary_config[:gradle_command] || @saved_config["gradle_command"] || "gradle"
    end

    def decisions_file
      if file_name = @primary_config[:decisions_file]
        return Pathname(file_name)
      end
      file_dir = @saved_config["decisions_file"] || "doc/dependency_decisions.yml"
      Pathname(file_dir)
    end
  end
end
