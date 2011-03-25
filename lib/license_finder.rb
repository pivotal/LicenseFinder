require 'pathname'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname
  def self.from_bundler
    require 'bundler'
    Bundler.load.specs.map { |spec| GemSpecDetails.new(spec) }.sort_by &:sort_order
  end

  def self.write_files
    bundler_list = DependencyList.from_bundler

    if(File.exists?('./dependencies.yml'))
      yml = File.open('./dependencies.yml').readlines.join
      existing_list = DependencyList.from_yaml(yml)
      new_list = existing_list.merge(bundler_list)
    else
      new_list = bundler_list
    end
    
    File.open('./dependencies.yml', 'w+') do |f|
      f.puts new_list.to_yaml
    end
    File.open('./dependencies.txt', 'w+') do |f|
      f.puts new_list.to_s
    end

  end
end

require 'forwardable'
require 'license_finder/railtie' if defined?(Rails)
require 'license_finder/gem_spec_details'
require 'license_finder/file_parser'
require 'license_finder/license_file'
require 'license_finder/readme_file'

require 'license_finder/dependency'
require 'license_finder/dependency_list'
