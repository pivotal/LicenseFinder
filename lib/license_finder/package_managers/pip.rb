require 'json'
require 'httparty'

module LicenseFinder
  class Pip
    def self.current_packages
      output = `python #{LicenseFinder::BIN_PATH.join("license_finder_pip.py")}`
      JSON(output).map do |package|
        PipPackage.new(
          package["name"],
          package["version"],
          File.join(package["location"], package["name"]),
          pypi_def(package["name"], package["version"])
        )
      end
    end

    def self.active?
      requirements_path.exist?
    end

    private

    def self.requirements_path
      Pathname.new('requirements.txt')
    end

    def self.pypi_def(name, version)
      response = HTTParty.get("https://pypi.python.org/pypi/#{name}/#{version}/json")
      if response.code == 200
        JSON.parse(response.body).fetch("info", {})
      else
        {}
      end
    end
  end
end
