require 'pathname'
require 'yaml'
require 'erb'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname

  Error = Class.new(StandardError)

  autoload :CLI,                  'license_finder/cli'
  autoload :DependencyManager,    'license_finder/dependency_manager'
  autoload :PackageSaver,         'license_finder/package_saver'
  autoload :License,              'license_finder/license'
  autoload :LicenseUrl,           'license_finder/license_url'
  autoload :PossibleLicenseFile,  'license_finder/possible_license_file'
  autoload :PossibleLicenseFiles, 'license_finder/possible_license_files'
  autoload :Configuration,        'license_finder/configuration'
  autoload :Platform,             'license_finder/platform'

  autoload :Bower,                'license_finder/bower'
  autoload :Bundler,              'license_finder/bundler'
  autoload :NPM,                  'license_finder/npm'
  autoload :Pip,                  'license_finder/pip'
  autoload :Package,              'license_finder/package'
  autoload :BowerPackage,         'license_finder/bower_package'
  autoload :BundlerPackage,       'license_finder/bundler_package'
  autoload :PipPackage,           'license_finder/pip_package'
  autoload :NpmPackage,           'license_finder/npm_package'

  autoload :BundlerGroup,         'license_finder/tables/bundler_group'
  autoload :Dependency,           'license_finder/tables/dependency'
  autoload :LicenseAlias,         'license_finder/tables/license_alias'
  autoload :YmlToSql,             'license_finder/yml_to_sql'

  autoload :DependencyReport,     'license_finder/reports/dependency_report'
  autoload :HtmlReport,           'license_finder/reports/html_report'
  autoload :MarkdownReport,       'license_finder/reports/markdown_report'
  autoload :Reporter,             'license_finder/reports/reporter'
  autoload :TextReport,           'license_finder/reports/text_report'
  autoload :DetailedTextReport,   'license_finder/reports/detailed_text_report'

  def self.config
    @config ||= Configuration.ensure_default
  end
end

require 'license_finder/railtie' if defined?(Rails)
unless defined?(LicenseAudit)
  require 'license_finder/tables'
  LicenseFinder::YmlToSql.convert_if_required
end
