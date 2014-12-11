require 'json'
require 'open3'

module LicenseFinder
  class Bower < PackageManager
    def current_packages
      output = nil
      Open3.popen3('bower list --json') do |i, o, e, w|
        output = o.read
      end

      json = JSON(output)

      json.fetch("dependencies",[]).map do |package|
        BowerPackage.new(package[1], logger: logger)
      end
    end

    private

    def package_path
      Pathname.new('bower.json')
    end
  end
end
