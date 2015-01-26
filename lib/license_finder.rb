require 'pathname'
require 'yaml'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname.join("license_finder")
  BIN_PATH = ROOT_PATH.join("../../bin")
end

require 'license_finder/platform'
require 'license_finder/version'
require 'license_finder/logger'
require 'license_finder/configuration'

require 'license_finder/license'

require 'license_finder/licensing'
require 'license_finder/activation'
require 'license_finder/possible_license_file'
require 'license_finder/license_files'
require 'license_finder/package'
require 'license_finder/package_manager'

require 'license_finder/decisions'
require 'license_finder/decision_applier'

require 'license_finder/core'

require 'license_finder/report'

require 'license_finder/cli'
