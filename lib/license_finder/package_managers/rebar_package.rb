module LicenseFinder
  class RebarPackage < Package
    def initialize(name, version, install_path, dep, options={})
      super(
        name,
        version,
        options.merge(
          homepage: dep["homepage"],
          install_path: install_path
        )
      )
    end
  end
end
