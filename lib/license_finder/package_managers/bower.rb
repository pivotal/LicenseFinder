require 'json'

module LicenseFinder
  class Bower
    def current_packages
      output = `bower list --json`

      json = JSON(output)

      json.fetch("dependencies",[]).map do |package|
        BowerPackage.new(package[1])
      end
    end

    def active?
      package_path.exist?
    end

    private

    def package_path
      Pathname.new('bower.json')
    end
  end
end
