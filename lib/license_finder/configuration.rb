require "delegate"

module LicenseFinder
  class Configuration
    def self.ensure_default
      Persistence.init
      prepare(Persistence.get)
    end

    def self.move!
      config = prepare(Persistence.get.merge('dependencies_file_dir' => './doc/'))
      config.save

      FileUtils.mv(Dir["dependencies*"], config.artifacts.dir)
    end

    # It's nice to keep destructive file system manipulation out of the
    # initializer.  That reduces test polution, but is slightly inconvenient
    # for methods like Configuration.ensure_default and Configuration.move!,
    # which need a working artifacts directory. This helper is a compromise.
    def self.prepare(config)
      result = new(config)
      result.artifacts.init
      result
    end

    attr_accessor :artifacts, :project_name, :gradle_command

    def initialize(config)
      @artifacts     = Artifacts.new(Pathname(config['dependencies_file_dir'] || './doc/'))
      @project_name  = config['project_name'] || determine_project_name
      @gradle_command = config['gradle_command'] || 'gradle'
    end

    def save
      Persistence.set(to_hash)
    end

    private

    def to_hash
      {
        'dependencies_file_dir' => artifacts.dir.to_s,
        'project_name' => project_name,
        'gradle_command' => gradle_command
      }
    end

    def determine_project_name
      Pathname.pwd.basename.to_s
    end

    class Artifacts < SimpleDelegator
      def init
        mkpath
      end

      def dir
        __getobj__
      end

      def decisions_file
        join("dependency_decisions.yml")
      end
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
        ROOT_PATH.join('data', 'license_finder.example.yml')
      end
    end
  end
end
