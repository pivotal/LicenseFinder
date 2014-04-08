require 'json'
require 'httparty'

module LicenseFinder
  class Pip
    GET_DEPENDENCIES_PY = <<-PYTHON.gsub(/\n+/, ";")
from pip.util import get_installed_distributions

dists = [(x.project_name, x.version, x.location) for x in get_installed_distributions()]
dists = ["[\\\"{0}\\\", \\\"{1}\\\", \\\"{2}\\\"]".format(*dist) for dist in dists]

print "[" + ",".join(dists) + "]"
    PYTHON

    def self.current_packages
      output = `python -c '#{GET_DEPENDENCIES_PY}'`

      JSON(output).map do |(name, version, install_dir)|
        PipPackage.new(
          name,
          version,
          File.join(install_dir, name),
          pypi_def(name, version)
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
