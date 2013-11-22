require 'json'
require 'license_finder/package'

module LicenseFinder
  class NPM

    def self.current_modules
      return @modules if @modules

      output = `npm list --json --long`

      json = JSON(output)

      @modules = json.fetch("dependencies",[]).map do |node_module|
        node_module = node_module[1]

        NpmPackage.new(node_module)
      end
    end

    def self.has_package?
      File.exists?(package_path)
    end

    private

    def self.package_path
      Pathname.new('package.json').expand_path
    end
  end
end
