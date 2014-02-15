require "rake"

module LicenseFinder
  class Configuration
    attr_accessor :whitelist, :ignore_groups, :dependencies_dir, :project_name

    module Persistence
      extend self

      def init!
        init unless inited?
      end

      def get
        return {} unless inited?

        YAML.load(file.read)
      end

      def set(hash)
        file.open('w') { |f| f.write(hash.to_yaml) }
      end

      private

      def inited?
        file.exist?
      end

      def init
        file_dir.mkpath
        FileUtils.cp(file_template, file)
      end

      def file_dir
        Pathname.new('.').join('config')
      end

      def file
        file_dir.join('license_finder.yml')
      end

      def file_template
        ROOT_PATH.join('..', 'files', 'license_finder.yml')
      end
    end

    def self.ensure_default
      Persistence.init!
      new(Persistence.get)
    end

    def self.move!
      config = new(Persistence.get.merge('dependencies_file_dir' => './doc/'))
      config.save

      FileUtils.mv(Dir["dependencies*"], config.dependencies_dir)
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
      Persistence.set(to_hash)
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
