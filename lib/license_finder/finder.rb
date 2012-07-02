module LicenseFinder
  class Finder

    attr_reader :whitelist, :ignore_groups
    def initialize
      config = case
        when File.exists?('./config/license_finder.yml')
          YAML.load(File.open('./config/license_finder.yml').readlines.join)
        else
          {}
      end

      @whitelist = config['whitelist'] || []
      @ignore_groups = (config['ignore_groups'] || []).map{|g| g.to_sym}
      @dependencies_dir = config['dependencies_file_dir']
    end

    def dependencies_dir
      @dependencies_dir || './'
    end

    def dependencies_yaml
      File.join(dependencies_dir, 'dependencies.yml')
    end

    def dependencies_text
      File.join(dependencies_dir, 'dependencies.txt')
    end

    def from_bundler
      require 'bundler'
      Bundler.load.specs.map { |spec| GemSpecDetails.new(spec) }.sort_by &:sort_order
    end

    def write_files
      new_list = generate_list

      File.open(dependencies_yaml, 'w+') do |f|
        f.puts new_list.to_yaml
      end
      File.open(dependencies_text, 'w+') do |f|
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

      if (File.exists?(dependencies_yaml))
        yml = File.open(dependencies_yaml).readlines.join
        existing_list = DependencyList.from_yaml(yml)
        existing_list.merge(bundler_list)
      else
        bundler_list
      end
    end
  end
end
