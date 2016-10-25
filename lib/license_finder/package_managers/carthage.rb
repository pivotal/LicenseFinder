require "json"

module LicenseFinder
  class Carthage < PackageManager
    def current_packages
      cartfile = IO.read(resolved_path)

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
      LicenseFinder::Platform.darwin? ? "carthage" : nil
    end

    private

    def package_path
      resolved_path
    end

    def public_dependency_path
      project_path.join("Cartfile")
    end

    def private_dependency_path
      project_path.join("Cartfile.private")
    end

    def resolved_path
      project_path.join("Cartfile.resolved")
    end

    def project_checkout(name)
      project_path.join("Carthage/Checkouts/#{name}")
    end

    def license_text(name)
      checkout_path = project_checkout name
      plain_text_path = checkout_path.join('LICENSE')
      md_path = checkout_path.join('LICENSE.md')
      markdown_path = checkout_path.join('LICENSE.markdown')
      license_path = nil
      if File.exists?(plain_text_path)
        license_path = plain_text_path
      elsif File.exists?(md_path)
        license_path = md_path
      elsif File.exists?(markdown_path)
        license_path = markdown_path
      end
      license_path.nil? ? nil : IO.read(license_path)
    end

    def name_version_from_line(cartfile_line)
      cartfile_line.split(' ')[1, 2].map { |f| f.split('/').last.gsub('"', '').gsub('.git', '') }
    end
  end
end