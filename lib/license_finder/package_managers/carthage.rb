require 'json'

module LicenseFinder
  class Carthage < PackageManager
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

    def self.package_management_command
      LicenseFinder::Platform.darwin? ? 'carthage' : nil
    end

    private

    def cartfile
      @cartfile ||= IO.read(resolved_path)
    end

    def package_path
      resolved_path
    end

    def resolved_path
      project_path.join('Cartfile.resolved')
    end

    def project_checkout(name)
      project_path.join('Carthage', 'Checkouts', name)
    end

    def license_text(name)
      license_path = license_pattern(name).find { |f| File.exists?(f) }
      license_path.nil? ? nil : IO.read(license_path)
    end

    def license_pattern(name)
      checkout_path = project_checkout(name)
      Dir.glob(checkout_path.join('LICENSE*'), File::FNM_CASEFOLD)
    end

    def name_version_from_line(cartfile_line)
      cartfile_line.split(' ')[1, 2].map { |f| f.split('/').last.gsub('"', '').gsub('.git', '') }
    end
  end
end
