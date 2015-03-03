require 'json'

module LicenseFinder
  class Bower < PackageManager
    def current_packages
      bower_output.map do |package|
        BowerPackage.new(package, logger: logger)
      end
    end

    private

    def bower_output
      output = `bower list --json -l action`

      JSON(output)
        .fetch("dependencies", {})
        .values
    end

    def package_path
      project_path.join('bower.json')
    end
  end
end
