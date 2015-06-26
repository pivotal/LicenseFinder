module LicenseFinder
  class GoPackage < Package
    def initialize(package_hash, options = {})
      name = package_hash['ImportPath'] ? package_hash['ImportPath'].split('/').last : nil
      version = package_hash['Rev'] ? package_hash['Rev'][0..6] : nil
      super(name, version, {install_path: "#{options[:install_prefix]}/#{package_hash['ImportPath']}"})
    end
  end
end
