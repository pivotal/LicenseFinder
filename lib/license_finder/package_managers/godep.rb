require 'json'

module LicenseFinder
  class Godep < PackageManager
    GODEP_WORKSPACE = 'Godeps/_workspace'
    GODEP_DEPENDENCIES = 'Godeps/Godeps.json'

    def current_packages
      json = JSON.parse(IO.read(GODEP_DEPENDENCIES))
      json['Deps'].map { |dep| GodepPackage.new(dep, install_prefix: "#{install_prefix}/src") }
    end

    def package_path
      project_path.join(GODEP_DEPENDENCIES)
    end

    private

    def install_prefix
      File.exist?(GODEP_WORKSPACE) ? GODEP_WORKSPACE : ENV['GOPATH']
    end
  end
end
