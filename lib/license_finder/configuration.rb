require "rake"

module LicenseFinder
  class Configuration
    attr_accessor :whitelist, :ignore_groups, :artifacts, :project_name

    def self.ensure_default
      Persistence.init
      default = new(Persistence.get)
      default.artifacts.init
      default
    end

    def self.move!
      config = new(Persistence.get.merge('dependencies_file_dir' => './doc/'))
      config.save

      config.artifacts.init
      FileUtils.mv(Dir["dependencies*"], config.artifats.dependencies_dir)
    end

    def initialize(config)
      @whitelist     = Array(config['whitelist'])
      @ignore_groups = Array(config["ignore_groups"])
      @artifacts     = Artifacts.new(Pathname(config['dependencies_file_dir'] || './doc/'))
      @project_name  = config['project_name'] || determine_project_name
    end

    class Artifacts < SimpleDelegator
      def init
        mkpath
      end

      def dependencies_dir
        __getobj__
      end

      def database_uri
        URI.escape(join("dependencies.db").expand_path.to_s)
      end

      def dependencies_text
        join("dependencies.csv")
      end

      def dependencies_detailed_text
        join("dependencies_detailed.csv")
      end

      def dependencies_html
        join("dependencies.html")
      end

      def dependencies_markdown
        join("dependencies.md")
      end

      def legacy_dependencies_yaml
        join("dependencies.yml")
      end

      def legacy_dependencies_text
        join("dependencies.txt")
      end
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
        'dependencies_file_dir' => artifacts.dependencies_dir.to_s,
        'project_name' => project_name
      }
    end

    def whitelisted_licenses
      whitelist.map do |license_name|
        License.find_by_name(license_name) || license_name
      end.compact
    end

    def determine_project_name
      Pathname.pwd.basename.to_s
    end

    module Persistence
      extend self

      def init
        init! unless inited?
      end

      def get
        return {} unless inited?

        YAML.load(file.read)
      end

      def set(hash)
        file.open('w') { |f| f.write(YAML.dump(hash)) }
      end

      private

      def inited?
        file.exist?
      end

      def init!
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
  end
end
