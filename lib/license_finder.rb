require 'pathname'
require 'yaml'
require 'erb'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname

  DEPENDENCY_ATTRIBUTES = [
    "name", "source", "version", "license", "license_url", "approved", "notes",
    "license_files", "readme_files", "bundler_groups", "summary",
    "description", "homepage", "children", "parents"
  ]

  autoload :Bundle, 'license_finder/bundle'
  autoload :BundledGem, 'license_finder/bundled_gem'
  autoload :CLI, 'license_finder/cli'
  autoload :Configuration, 'license_finder/configuration'
  autoload :Dependency, 'license_finder/dependency'
  autoload :DependencyList, 'license_finder/dependency_list'
  autoload :License, 'license_finder/license'
  autoload :LicenseUrl, 'license_finder/license_url'
  autoload :PossibleLicenseFile, 'license_finder/possible_license_file'
  autoload :Reporter, 'license_finder/reporter'
  autoload :HtmlReport, 'license_finder/html_report'
  autoload :TextReport, 'license_finder/text_report'
  autoload :DependencyReport, 'license_finder/dependency_report'
  autoload :BundleSyncer, 'license_finder/bundle_syncer'
  autoload :Persistence, 'license_finder/persistence/yaml'

  def self.config
    @config ||= Configuration.new
  end

  def self.load_rake_tasks
    load 'tasks/license_finder.rake'
  end
end

require 'license_finder/railtie' if defined?(Rails)
