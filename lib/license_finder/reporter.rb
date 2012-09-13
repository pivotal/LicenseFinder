module LicenseFinder
  class Reporter
    def initialize
      @dependency_list = generate_list
      save_reports
    end

    def action_items
      dependency_list.action_items
    end

    private

    attr_reader :dependency_list
    def save_reports
      write_file LicenseFinder.config.dependencies_yaml, dependency_list.to_yaml
      write_file LicenseFinder.config.dependencies_text, dependency_list.to_s
      write_file LicenseFinder.config.dependencies_html, dependency_list.to_html
    end

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
