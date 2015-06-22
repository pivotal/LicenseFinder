module LicenseFinder
  class GodepPackage < Package
    def initialize(package_hash)
      name = package_hash['ImportPath'] ? package_hash['ImportPath'].split('/').last : nil
      version = package_hash['Rev'] ? package_hash["Rev"][0..6] : nil
      install_path = "#{ENV['GOPATH']}/src/#{package_hash['ImportPath']}"
      super(name, version, {install_path: install_path})
    end
  end
end
