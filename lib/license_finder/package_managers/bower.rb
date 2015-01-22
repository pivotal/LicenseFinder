require 'json'

module LicenseFinder
  class Bower < PackageManager
    def current_packages
      output = `bower list --json -l action`

      json = JSON(output)

      json.fetch("dependencies",[]).map do |package|
        BowerPackage.new(package[1], logger: logger)
      end
    end

    private

    def package_path
      project_path.join('bower.json')
    end
  end
end
