# frozen_string_literal: true

require 'pathname'
require 'yaml'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname.join('license_finder')
  BIN_PATH = ROOT_PATH.join('../../bin')
end

require 'license_finder/shared_helpers/cmd'

require 'license_finder/core'
require 'license_finder/cli'
