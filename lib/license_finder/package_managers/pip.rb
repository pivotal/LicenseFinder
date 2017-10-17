require 'json'
require 'httparty'

module LicenseFinder
  class Pip < PackageManager
    def initialize(options={})
      super
      @requirements_path = options[:pip_requirements_path] || Pathname('requirements.txt')
    end

    def current_packages
      pip_output.map do |name, version, children, location|
        PipPackage.new(
          name,
          version,
          pypi_def(name, version),
          logger: logger,
          children: children,
          install_path: Pathname(location).join(name),
        )
      end
    end

    def self.package_management_command
      "pip"
    end

    private

    def possible_package_paths
      unless project_path.nil?
        [project_path.join(@requirements_path)]
      else
        [@requirements_path]
      end
    end

    def pip_output
      output = `#{LicenseFinder::BIN_PATH.join("license_finder_pip.py")} #{detected_package_path}`
      JSON(output).map do |package|
        package.values_at(*%w[name version dependencies location])
      end
    end

    def pypi_def(name, version)
      response = HTTParty.get("https://pypi.python.org/pypi/#{name}/#{version}/json")
      if response.code == 200
        JSON.parse(response.body).fetch("info", {})
      else
        {}
      end
    end
  end
end
