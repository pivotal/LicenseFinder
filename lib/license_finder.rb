require 'pathname'
require 'license_finder/finder'
require 'license_finder/license_file'

module LicenseFinder
  def self.from_bundler
    require 'bundler'
    Bundler.load.specs.map { |spec| Finder.new(spec) }.sort_by &:sort_order
  end
end
