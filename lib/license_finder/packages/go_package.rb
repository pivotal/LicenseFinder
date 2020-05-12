# frozen_string_literal: true

require 'license_finder/package'

module LicenseFinder
  class GoPackage < Package
    def package_manager
      'Go'
    end

    def package_url
      "https://pkg.go.dev/#{CGI.escape(name)}@#{CGI.escape(version)}"
    end

    class << self
      def from_dependency(hash, prefix, full_version)
        name = hash['ImportPath']
        install_path = hash['InstallPath']
        install_path ||= install_path(prefix.join(name))
        version = full_version ? hash['Rev'].gsub('+incompatible', '') : hash['Rev'][0..6]
        homepage = hash['Homepage']
        new(name, version, install_path: install_path, package_manager: 'Go', homepage: homepage)
      end

      private

      def install_path(path)
        Pathname(path).cleanpath.to_s
      end
    end
  end
end
