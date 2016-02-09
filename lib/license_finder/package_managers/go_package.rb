module LicenseFinder
  class GoPackage < Package
    def self.from_dependency(hash, prefix,full_version)
      name = hash['ImportPath']
      install_path = hash['InstallPath']
      install_path ||= install_path(prefix.join(name))
      version = full_version ? hash['Rev'] : hash['Rev'][0..6]
      LicenseFinder::Package.new(name, version, {install_path: install_path})
    end

    private

    def self.install_path(path)
      Pathname(path).cleanpath.to_s
    end
  end
end
