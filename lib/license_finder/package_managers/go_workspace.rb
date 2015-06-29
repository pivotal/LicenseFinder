require 'json'

module LicenseFinder
  class GoWorkspace < PackageManager
    def current_packages
      go_output.map do |package|
        GoPackage.new(package, logger:logger)
      end
    end

    def package_path
      project_path.join('.envrc')
    end

    private

    def go_output
      cmd_text = `cd #{project_path}; go list -f "{{.ImportPath}} " ./...`
      paths = cmd_text.gsub(/\s{2,}/, ",").split(",")
      paths.map do |path|
        {
          'ImportPath' => format_path(path),
          'Rev' => 'unknown'
        }
      end
    end

    def format_path(path)
      path[2..-1]
    end
  end
end
