require 'pathname'
require 'yaml'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname

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

  def self.config
    @config ||= Configuration.new
  end

  def self.load_rake_tasks
    load 'tasks/license_finder.rake'
  end
end

require 'license_finder/railtie' if defined?(Rails)
require 'license_finder/reporter'
require 'license_finder/bundle'
require 'license_finder/bundled_gem'
require 'license_finder/license'
require 'license_finder/possible_license_file'
require 'license_finder/viewable'
require 'license_finder/dependency'
require 'license_finder/dependency_list'
require 'license_finder/cli'
require 'license_finder/license_url'
