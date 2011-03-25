require 'pathname'
require 'yaml'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname
end

require 'license_finder/railtie' if defined?(Rails)
require 'license_finder/finder'
require 'license_finder/gem_spec_details'
require 'license_finder/file_parser'
require 'license_finder/license_file'
require 'license_finder/readme_file'

require 'license_finder/dependency'
require 'license_finder/dependency_list'
