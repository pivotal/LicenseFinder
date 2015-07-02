module LicenseFinder
  class GoPackage < Package
    def initialize(package_hash, options = {})
      name = options[:package_name] || package_hash['ImportPath'].split('/').last
      version = package_hash['Rev'] ? package_hash['Rev'][0..6] : nil
      install_path = Pathname("#{options[:install_prefix]}/#{package_hash['ImportPath']}")
      super(name, version, {install_path: install_path.cleanpath.to_s})
    end
  end
end
