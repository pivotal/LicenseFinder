require 'json'

module LicenseFinder
  class NPM
    def self.current_packages
      output = `npm list --json --long`

      JSON(output).fetch("dependencies",[]).map do |(_, node_module)|
        NpmPackage.new(node_module)
      end
    end

    def self.active?
      File.exists?(package_path)
    end

    private

    def self.package_path
      Pathname.new('package.json').expand_path
    end
  end
end
