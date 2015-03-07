module LicenseFinder
  module CLI
  end
end

require 'license_finder/cli/patched_thor'

require 'license_finder/cli/base'
require 'license_finder/cli/makes_decisions'

require 'license_finder/cli/whitelist'
require 'license_finder/cli/blacklist'
require 'license_finder/cli/dependencies'
require 'license_finder/cli/licenses'
require 'license_finder/cli/approvals'
require 'license_finder/cli/ignored_groups'
require 'license_finder/cli/ignored_dependencies'
require 'license_finder/cli/project_name'

require 'license_finder/cli/main'
