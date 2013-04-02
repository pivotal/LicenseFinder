require 'pathname'
require 'yaml'
require 'erb'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname

  DEPENDENCY_ATTRIBUTES = [
    "name", "version", "license", "license_url", "approved", "notes",
    "license_files", "bundler_groups", "summary",
    "description", "homepage", "children", "parents", "manual"
  ]

  autoload :Bundle, 'license_finder/bundle'
  autoload :BundledGem, 'license_finder/bundled_gem'
  autoload :CLI, 'license_finder/cli'
  autoload :Configuration, 'license_finder/configuration'
  autoload :License, 'license_finder/license'
  autoload :LicenseUrl, 'license_finder/license_url'
  autoload :PossibleLicenseFile, 'license_finder/possible_license_file'
  autoload :DependencyReport, 'license_finder/dependency_report'
  autoload :HtmlReport, 'license_finder/html_report'
  autoload :TextReport, 'license_finder/text_report'
  autoload :Reporter, 'license_finder/reporter'
  autoload :BundleSyncer, 'license_finder/bundle_syncer'
  autoload :YmlToSql, 'license_finder/yml_to_sql'
  autoload :Dependency, 'license_finder/tables/dependency'
  autoload :Approval, 'license_finder/tables/approval'
  autoload :LicenseAlias, 'license_finder/tables/license_alias'
  autoload :BundlerGroup, 'license_finder/tables/bundler_group'
  autoload :GemSaver, 'license_finder/gem_saver'

  def self.config
    @config ||= Configuration.ensure_default
  end

  def self.load_rake_tasks
    load 'tasks/license_finder.rake'
  end
end

require 'license_finder/railtie' if defined?(Rails)

LicenseFinder::YmlToSql.convert_if_required
