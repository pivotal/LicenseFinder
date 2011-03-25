require 'pathname'

module LicenseFinder
  ROOT_PATH = Pathname.new(__FILE__).dirname

  class << self
    def from_bundler
      require 'bundler'
      Bundler.load.specs.map { |spec| GemSpecDetails.new(spec) }.sort_by &:sort_order
    end

    def write_files
      new_list = generate_list
      
      File.open('./dependencies.yml', 'w+') do |f|
        f.puts new_list.to_yaml
      end
      File.open('./dependencies.txt', 'w+') do |f|
        f.puts new_list.to_s
      end

    end

    def action_items
      new_list = generate_list
      new_list.action_items
    end

    private
    def generate_list
      bundler_list = DependencyList.from_bundler

      if (File.exists?('./dependencies.yml'))
        yml = File.open('./dependencies.yml').readlines.join
        existing_list = DependencyList.from_yaml(yml)
        existing_list.merge(bundler_list)
      else
        bundler_list
      end
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
