# frozen_string_literal: true

require 'json'

module LicenseFinder
  class Carthage < PackageManager
    class CarthageError < RuntimeError; end

    def current_packages
      cartfile.each_line.map do |line|
        name, version = name_version_from_line line

        CarthagePackage.new(
          name,
          version,
          license_text(name),
          logger: logger,
          install_path: project_checkout(name)
        )
      end
    end

    def package_management_command
      LicenseFinder::Platform.darwin? ? 'carthage' : nil
    end

    def possible_package_paths
      [public_dependency_path]
    end

    private

    def cartfile
      if File.exist?(resolved_path)
        @cartfile ||= IO.read(resolved_path)
      else
        raise CarthageError, 'No Cartfile.resolved found.
          Please install your dependencies first.'
      end
    end

    def public_dependency_path
      project_path.join('Cartfile')
    end

    def resolved_path
      project_path.join('Cartfile.resolved')
    end

    def project_checkout(name)
      project_path.join('Carthage', 'Checkouts', name)
    end

    def license_text(name)
      license_path = license_pattern(name).find { |f| File.exist?(f) }
      license_path.nil? ? nil : IO.read(license_path)
    end

    def license_pattern(name)
      checkout_path = project_checkout(name)
      Dir.glob(checkout_path.join('LICENSE*'), File::FNM_CASEFOLD)
    end

    def name_version_from_line(cartfile_line)
      cartfile_line.split(' ')[1, 2].map { |f| f.split('/').last.delete('"').gsub('.git', '') }
    end
  end
end
