require 'json'

module LicenseFinder
  class Godep < PackageManager
    def current_packages
      json = JSON.parse(IO.read('Godeps/Godeps.json'))
      json['Deps'].map { |dep| GodepPackage.new(dep) }
    end

    def package_path
      project_path.join('Godeps/Godeps.json')
    end 
  end
end
