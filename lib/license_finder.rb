require 'pathname'
require 'yaml'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname

  class Configuration
    attr_reader :whitelist, :ignore_groups, :dependencies_dir

    def initialize
      config = {}

      if File.exists?('./config/license_finder.yml')
        yaml = File.open('./config/license_finder.yml').readlines.join
        config = YAML.load(yaml)
      end

      @whitelist = config['whitelist'] || []
      @ignore_groups = (config["ignore_groups"] || []).map(&:to_sym)
      @dependencies_dir = config['dependencies_file_dir'] || '.'
    end

    def dependencies_yaml
      File.join(dependencies_dir, "dependencies.yml")
    end

    def dependencies_text
      File.join(dependencies_dir, "dependencies.txt")
    end
  end

  def self.config
    @config ||= Configuration.new
  end
end

require 'license_finder/railtie' if defined?(Rails)
require 'license_finder/finder'
require 'license_finder/gem_spec_details'
require 'license_finder/license'
require 'license_finder/possible_license_file'
require 'license_finder/dependency'
require 'license_finder/dependency_list'
require 'license_finder/cli'
