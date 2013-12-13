require 'json'
require 'license_finder/package'

module LicenseFinder
  class Bower

    def self.current_packages
      return @packages if @packages

      output = `bower list --json`

      json = JSON(output)

      @packages = json.fetch("dependencies",[]).map do |package|
        package = package[1]
        pkg_meta = package.fetch("pkgMeta", Hash.new)

        Package.new(OpenStruct.new(
          :name => pkg_meta.fetch("name", nil),
          :version => pkg_meta.fetch("version", nil),
          :full_gem_path => package.fetch("canonicalDir", nil),
          :license => self.harvest_license(pkg_meta),
          :summary => pkg_meta.fetch("description", nil),
          :description => pkg_meta.fetch("readme", nil)
        ))
      end
    end

    def self.has_package_file?
      File.exists?(package_path)
    end

    private

    def self.package_path
      Pathname.new('bower.json').expand_path
    end

    def self.harvest_license(package)
      license = package.fetch("licenses", []).first

      if license.is_a? Hash
        license = license.fetch("type", nil)
      end

      if license.nil?
        license = package.fetch("license", nil)

        if license.is_a? Hash
          license = license.fetch("type", nil)
        end
      end

      license
    end
  end
end
