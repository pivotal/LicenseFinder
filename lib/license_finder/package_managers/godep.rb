require 'json'

module LicenseFinder
  class Godep < PackageManager
    def package_path
      project_path.join('Godeps/Godeps.json')
    end 

    def godep_project?
      File.exist?('Godeps/Godeps.json')
    end
  end
end
