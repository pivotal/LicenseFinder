module LicenseFinder
  class Configuration
    attr_reader :whitelist, :ignore_groups, :dependencies_dir

    def initialize
      config = {}

      if File.exists?(config_file_path)
        yaml = File.open(config_file_path).readlines.join
        config = YAML.load(yaml)
      end

      @whitelist = config['whitelist'] || []
      @ignore_groups = (config["ignore_groups"] || []).map(&:to_sym)
      @dependencies_dir = config['dependencies_file_dir'] || '.'
    end

    def config_file_path
      File.join('.', 'config', 'license_finder.yml')
    end

    def dependencies_yaml
      File.join(dependencies_dir, "dependencies.yml")
    end

    def dependencies_text
      File.join(dependencies_dir, "dependencies.txt")
    end

    def dependencies_html
      File.join(dependencies_dir, "dependencies.html")
    end
  end
end
