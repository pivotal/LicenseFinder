module LicenseFinder
  class GodepPackage < Package
    def initialize(package_hash, options={})
      name = package_hash["ImportPath"] ? package_hash["ImportPath"].split("/").last : nil
      rev = package_hash["Rev"] ? package_hash["Rev"][0..6] : nil
      super(
        name,
        rev,
        options.merge(
          install_path: package_hash["ImportPath"],
          spec_licenses: Array(package_hash["Licenses"]).map { |l| l["name"] }
        )
      )
    end
  end
end
