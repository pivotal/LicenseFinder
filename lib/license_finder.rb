require 'pathname'
require 'yaml'
require 'erb'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname

  Error = Class.new(StandardError)

  autoload :Bundle,               'license_finder/bundle'
  autoload :BundledGem,           'license_finder/bundled_gem'
  autoload :BundledGemSaver,      'license_finder/bundled_gem_saver'
  autoload :CLI,                  'license_finder/cli'
  autoload :Configuration,        'license_finder/configuration'
  autoload :DependencyManager,    'license_finder/dependency_manager'
  autoload :License,              'license_finder/license'
  autoload :LicenseUrl,           'license_finder/license_url'
  autoload :Platform,             'license_finder/platform'
  autoload :PossibleLicenseFile,  'license_finder/possible_license_file'
  autoload :PossibleLicenseFiles, 'license_finder/possible_license_files'
  autoload :YmlToSql,             'license_finder/yml_to_sql'

  autoload :Approval,     'license_finder/tables/approval'
  autoload :BundlerGroup, 'license_finder/tables/bundler_group'
  autoload :Dependency,   'license_finder/tables/dependency'
  autoload :LicenseAlias, 'license_finder/tables/license_alias'

  autoload :DependencyReport, 'license_finder/reports/dependency_report'
  autoload :HtmlReport,       'license_finder/reports/html_report'
  autoload :Reporter,         'license_finder/reports/reporter'
  autoload :TextReport,       'license_finder/reports/text_report'

  def self.config
    @config ||= Configuration.ensure_default
  end

  def self.load_rake_tasks
    load 'tasks/license_finder.rake'
  end
end

unless defined?(Rails)
  require 'license_finder/tables'
  LicenseFinder::YmlToSql.convert_if_required
end
