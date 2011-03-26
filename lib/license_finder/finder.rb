module LicenseFinder
  class Finder

    attr_reader :whitelist, :ignore_groups
    def initialize
      if File.exists?('./config/license_finder.yml')
        config = YAML.load(File.open('./config/license_finder.yml').readlines.join)
        @whitelist = config['whitelist'] || []
        @ignore_groups = config['ignore_groups'] ? config['ignore_groups'].map{|g| g.to_sym} : []
      end
    end

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
      bundler_list = DependencyList.from_bundler(whitelist, ignore_groups)

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