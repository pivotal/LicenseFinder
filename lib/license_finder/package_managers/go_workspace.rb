require 'json'

module LicenseFinder
  class GoWorkspace < PackageManager
    def current_packages
      logger.log(self.class, 'Go workspace projects are not supported')
      []
    end

    def package_path
      project_path.join('.envrc')
    end
  end
end
