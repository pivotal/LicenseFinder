module LicenseFinder
  class Finder
    def from_bundler
      require 'bundler'
      Bundler.load.specs.map { |spec| GemSpecDetails.new(spec) }.sort_by &:sort_order
    end

    def write_files
      new_list = generate_list

      File.open(LicenseFinder.config.dependencies_yaml, 'w+') do |f|
        f.puts new_list.to_yaml
      end
      File.open(LicenseFinder.config.dependencies_text, 'w+') do |f|
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

      if File.exists?(LicenseFinder.config.dependencies_yaml)
        yml = File.open(LicenseFinder.config.dependencies_yaml).readlines.join
        existing_list = DependencyList.from_yaml(yml)
        existing_list.merge(bundler_list)
      else
        bundler_list
      end
    end
  end
end
