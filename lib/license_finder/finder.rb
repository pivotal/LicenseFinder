module LicenseFinder
  class Finder
    def generate_reports
      new_list = generate_list

      write_file LicenseFinder.config.dependencies_yaml, new_list.to_yaml
      write_file LicenseFinder.config.dependencies_text, new_list.to_s
      write_file LicenseFinder.config.dependencies_html, new_list.to_html
    end

    def action_items
      new_list = generate_list
      new_list.action_items
    end

    private

    def write_file(file_path, content)
      File.open(file_path, 'w+') do |f|
        f.puts content
      end
    end

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
