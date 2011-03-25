require 'pathname'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname
  def self.from_bundler
    require 'bundler'
    Bundler.load.specs.map { |spec| Finder.new(spec) }.sort_by &:sort_order
  end

  def self.to_yml
    yml_string = self.from_bundler.map { |lf| lf.to_s(ARGV.first == "--with-licenses") }.join

    if (File.exists?('./config'))
      File.open('./config/dependencies.yml', 'w+') do |f|
        f.puts yml_string
      end
    end
  end
end

require 'forwardable'
require 'license_finder/railtie' if defined?(Rails)
require 'license_finder/finder'
require 'license_finder/file_parser'
require 'license_finder/license_file'
require 'license_finder/readme_file'

require 'license_finder/dependency'
require 'license_finder/dependency_list'
