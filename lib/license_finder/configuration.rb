module LicenseFinder
  class Configuration
    attr_accessor :whitelist, :ignore_groups, :dependencies_dir

    def self.config_file_path
      File.join('.', 'config', 'license_finder.yml')
    end

    def self.ensure_default
      make_config_file unless File.exists?(config_file_path)
      new
    end

    def self.make_config_file
      FileUtils.mkdir_p(File.join('.', 'config'))
      FileUtils.cp(
        ROOT_PATH.join('..', 'files', 'license_finder.yml'),
        config_file_path
      )
    end

    def self.move!
      config = config_hash('dependencies_file_dir' => './doc/')
      File.open(config_file_path, 'w') do |f|
        f.write YAML.dump(config)
      end

      FileUtils.mkdir_p("doc")
      FileUtils.mv(Dir["dependencies.*"], "doc")
    end

    def self.config_hash(config)
      if File.exists?(config_file_path)
        yaml = File.read(config_file_path)
        config = YAML.load(yaml).merge config
      end
      config
    end

    def initialize(config={})
      config = self.class.config_hash(config)

      @whitelist = config['whitelist'] || []
      @ignore_groups = (config["ignore_groups"] || []).map(&:to_sym)
      @dependencies_dir = config['dependencies_file_dir'] || './doc/'
      FileUtils.mkdir_p(@dependencies_dir)
    end

    def database_uri
      URI.escape(File.expand_path(File.join(dependencies_dir, "dependencies.db")))
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

    def ignore_groups
      @ignore_groups.map &:to_sym
    end

    def whitelisted?(license_name)
      license = License.find_by_name(license_name) || license_name
      whitelisted_licenses.include? license
    end

    private

    def whitelisted_licenses
      whitelist.map do |license_name|
        License.find_by_name(license_name) || license_name
      end.compact
    end
  end
end
