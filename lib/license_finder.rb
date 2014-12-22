require 'pathname'
require 'yaml'
require 'erb'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname
  BIN_PATH = ROOT_PATH.join("../bin")

  autoload :Logger,               'license_finder/logger'
  autoload :CLI,                  'license_finder/cli'
  autoload :Decisions,            'license_finder/decisions'
  autoload :DecisionApplier,      'license_finder/decision_applier'
  autoload :License,              'license_finder/license'
  autoload :PossibleLicenseFile,  'license_finder/possible_license_file'
  autoload :PossibleLicenseFiles, 'license_finder/possible_license_files'
  autoload :Configuration,        'license_finder/configuration'
  autoload :Platform,             'license_finder/platform'

  autoload :Package,              'license_finder/package'
  autoload :PackageManager,       'license_finder/package_manager'

  autoload :DependencyReport,     'license_finder/reports/dependency_report'
  autoload :FormattedReport,      'license_finder/reports/formatted_report'
  autoload :CsvReport,            'license_finder/reports/csv_report'
  autoload :HtmlReport,           'license_finder/reports/html_report'
  autoload :MarkdownReport,       'license_finder/reports/markdown_report'
  autoload :TextReport,           'license_finder/reports/text_report'
  autoload :DetailedTextReport,   'license_finder/reports/detailed_text_report'
  autoload :StatusReport,         'license_finder/reports/status_report'

  def self.config
    @config ||= Configuration.ensure_default
  end
end
