require 'json'

module LicenseFinder
  class GoDep < PackageManager
    def current_packages
      json = JSON.parse(package_path.read)
      json['Deps'].map { |dep| GoPackage.from_dependency(dep, install_prefix) }
    end

    def package_path
      project_path.join('Godeps/Godeps.json')
    end

    private

    def install_prefix
      go_path = workspace_dir.exist? ? workspace_dir : Pathname(ENV['GOPATH'])
      go_path.join('src')
    end

    def workspace_dir
      project_path.join('Godeps/_workspace')
    end
  end
end
