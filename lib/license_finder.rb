require 'pathname'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname
  def self.from_bundler
    require 'bundler'
    Bundler.load.specs.map { |spec| Finder.new(spec) }.sort_by &:sort_order
  end
end

require 'license_finder/finder'
require 'license_finder/file_parser'
require 'license_finder/license_file'
require 'license_finder/readme_file'
