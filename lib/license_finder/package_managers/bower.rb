require 'json'

module LicenseFinder
  class Bower

    def self.current_packages
      output = `bower list --json`

      json = JSON(output)

      json.fetch("dependencies",[]).map do |package|
        BowerPackage.new(package[1])
      end
    end

    def self.active?
      File.exists?(package_path)
    end

    private

    def self.package_path
      Pathname.new('bower.json').expand_path
    end
  end
end
