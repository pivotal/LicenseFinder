# frozen_string_literal: true

module LicenseFinder
  class GitSubmodulePackage < Package
    def initialize(name, version, path, url = '')
      super(
        name,
        version,
        {
          install_path: path,
          package_url: url
        }
      )
    end

    def package_manager
      'Git Submodule'
    end
  end
end
