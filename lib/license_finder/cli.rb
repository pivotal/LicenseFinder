module LicenseFinder
  module CLI
    extend self

    def create_default_configuration
      unless File.exists?(LicenseFinder.config.config_file_path)
        `mkdir -p ./config`
        FileUtils.cp(
          File.join(File.dirname(__FILE__), '..', '..', 'files', 'license_finder.yml'),
          LicenseFinder.config.config_file_path
        )
      end
    end

    def check_for_action_items
      found = LicenseFinder::Reporter.new.action_items

      if found.size == 0
        puts "All gems are approved for use"
        exit 0
      else
        puts "Dependencies that need approval:"
        puts found
        exit 1
      end
    end
  end
end
