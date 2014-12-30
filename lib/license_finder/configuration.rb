require "delegate"

module LicenseFinder
  class SimpleConfig
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
      file_dir = @saved_config["dependencies_file_dir"] || "./doc/"
      Pathname(file_dir).join("dependency_decisions.yml")
    end
  end

  class Configuration
    def self.ensure_default
      Persistence.init
      prepare(Persistence.get)
    end

    # It's nice to keep destructive file system manipulation out of the
    # initializer.  That reduces test polution, but is slightly inconvenient
    # for methods like Configuration.ensure_default, which need a working
    # artifacts directory. This helper is a compromise.
    def self.prepare(config)
      result = new(config)
      result.artifacts.init
      result
    end

    attr_accessor :artifacts

    def initialize(config)
      @artifacts     = Artifacts.new(Pathname(config['dependencies_file_dir'] || './doc/'))
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
