require "rake"

module LicenseFinder
  class Configuration
    attr_accessor :whitelist, :ignore_groups, :dependencies_dir, :project_name

    def self.config_file_path
      File.join('.', 'config', 'license_finder.yml')
    end

    def self.ensure_default
      make_config_file unless config_file_exists?
      new(persisted_config_hash)
    end

    def self.config_file_exists?
      File.exists?(config_file_path)
    end

    def self.make_config_file
      FileUtils.mkdir_p(File.join('.', 'config'))
      FileUtils.cp(
        ROOT_PATH.join('..', 'files', 'license_finder.yml'),
        config_file_path
      )
    end

    def self.move!
      config = new(persisted_config_hash.merge('dependencies_file_dir' => './doc/'))
      config.save

      FileUtils.mv(Dir["dependencies*"], config.dependencies_dir)
    end

    def self.persisted_config_hash
      if config_file_exists?
        yaml = File.read(config_file_path)
        YAML.load(yaml)
      else
        {}
      end
    end

    def self.save(config_hash)
      File.open(config_file_path, 'w') do |file|
        file.write(config_hash.to_yaml)
      end
    end

    def initialize(config={})
      @whitelist = config['whitelist'] || []
      @ignore_groups = (config["ignore_groups"] || [])
      @dependencies_dir = config['dependencies_file_dir'] || './doc/'
      @project_name = config['project_name'] || determine_project_name
      FileUtils.mkdir_p(dependencies_dir)
    end

    def database_uri
      URI.escape(File.expand_path(File.join(dependencies_dir, "dependencies.db")))
    end

    def dependencies_yaml
      File.join(dependencies_dir, "dependencies.yml")
    end

    def dependencies_text
      File.join(dependencies_dir, "dependencies.csv")
    end

    def dependencies_detailed_text
      File.join(dependencies_dir, "dependencies_detailed.csv")
    end

    def dependencies_legacy_text
      File.join(dependencies_dir, "dependencies.txt")
    end

    def dependencies_html
      File.join(dependencies_dir, "dependencies.html")
    end

    def dependencies_markdown
      File.join(dependencies_dir, "dependencies.md")
    end

    def whitelisted?(license_name)
      license = License.find_by_name(license_name) || license_name
      whitelisted_licenses.include? license
    end

    def save
      Configuration.save(to_hash)
    end

    private

    def to_hash
      {
        'whitelist' => whitelist.uniq,
        'ignore_groups' => ignore_groups.uniq,
        'dependencies_file_dir' => dependencies_dir,
        'project_name' => project_name
      }
    end

    def whitelisted_licenses
      whitelist.map do |license_name|
        License.find_by_name(license_name) || license_name
      end.compact
    end

    def determine_project_name
      File.basename(Dir.getwd)
    end
  end
end
