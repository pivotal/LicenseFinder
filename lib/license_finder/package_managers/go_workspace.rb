require 'json'

module LicenseFinder
  class GoWorkspace < PackageManager
    def current_packages
      package_paths.map do |package_path|
        package_name = Pathname(package_path).relative_path_from(project_src).to_s
        GoPackage.from_workspace(package_name, package_path)
      end
    end

    def package_path
      project_path.join('.envrc')
    end

    def active?
      active = package_path.exist? && IO.read(package_path).include?('GOPATH')
      active.tap { |is_active| logger.active self.class, is_active }
    end

    private

    def project_src
      project_path.join('src')
    end

    def package_paths
      imports = `cd #{project_path} && go list -f "{{.ImportPath}} " ./...`
      imports.gsub(/\s{2,}/, ',').split(',').map { |path| path[1..-1] }
    end
  end
end
