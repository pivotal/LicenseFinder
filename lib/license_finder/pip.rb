require 'json'
require 'httparty'
require 'license_finder/package'

module LicenseFinder
  class Pip
    GET_DEPENDENCIES_PY = <<-PYTHON
from pip.util import get_installed_distributions

dists = [(x.project_name, x.version, x.location) for x in get_installed_distributions()]
dists = ["[\\\"{0}\\\", \\\"{1}\\\", \\\"{2}\\\"]".format(*dist) for dist in dists]

print "[" + ",".join(dists) + "]"
    PYTHON

    def self.current_dists
      return @dists if @dists

      command = GET_DEPENDENCIES_PY.gsub(/\n+/, ";")

      output = `python -c '#{command}'`

      @dists = JSON(output).map do |dist_ary|
        PythonPackage.new(OpenStruct.new(
          :name => dist_ary[0],
          :version => dist_ary[1],
          :full_gem_path => File.join(dist_ary[2], dist_ary[0])
        ))
      end
    end

    def self.has_requirements?
      File.exists?(requirements_path)
    end

    def self.license_for(package)
      info = package.json
      license = info.fetch("license", "UNKNOWN")

      if license == "UNKNOWN"
        classifiers = info.fetch("classifiers", [])
        license = classifiers.map do |c|
          if c.start_with?("License")
            c.gsub(/^License.*::\s*(.*)$/, '\1')
          end
        end.compact.first
      end

      license || "other"
    end

    private

    def self.requirements_path
      Pathname.new('requirements.txt').expand_path
    end
  end
end
