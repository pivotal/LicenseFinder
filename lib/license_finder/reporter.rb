module LicenseFinder
  class Reporter
    def self.create_default_configuration
      unless File.exists?(LicenseFinder.config.config_file_path)
        FileUtils.mkdir_p(File.join('.', 'config'))
        FileUtils.cp(
          File.join(File.dirname(__FILE__), '..', '..', 'files', 'license_finder.yml'),
          LicenseFinder.config.config_file_path
        )
      end
    end

    def initialize
      self.class.create_default_configuration
      @dependency_list = generate_list
      save_reports
    end

    def action_items
      dependency_list.action_items
    end

    private

    attr_reader :dependency_list

    def save_reports
      dependency_list.save!
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
