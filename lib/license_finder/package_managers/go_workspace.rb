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
        {'ImportPath' => format_package_name(path)}
      end
    end

    def format_package_name(name)
      formatted_name = name.sub(/^.{1,}src\//, '') #strip root dir
      name_arr = formatted_name.split('/')
      (name_arr.length > 2 ? name_arr[1..-1] : name_arr).join('-')
    end
  end
end
