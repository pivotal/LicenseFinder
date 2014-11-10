require 'json'

module LicenseFinder
  class Bower < PackageManager
    def current_packages
      output = `bower list --json`

      json = JSON(output)

      json.fetch("dependencies",[]).map do |package|
        BowerPackage.new(package[1], logger: logger)
      end
    end

    private

    def package_path
      Pathname.new('bower.json')
    end
  end
end
