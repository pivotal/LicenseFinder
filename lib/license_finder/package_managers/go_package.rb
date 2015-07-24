module LicenseFinder
  class GoPackage < Package
    def self.from_workspace(name, path)
      LicenseFinder::Package.new(name, 'unknown', {install_path: install_path(path)})
    end

    def self.from_dependency(hash, prefix)
      name = hash['ImportPath']
      version = hash['Rev'][0..6]
      LicenseFinder::Package.new(name, version, {install_path: install_path(prefix.join(name))})
    end

    private

    def self.install_path(path)
      Pathname(path).cleanpath.to_s
    end
  end
end
