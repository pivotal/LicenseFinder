module LicenseFinder
  module LicenseUrl
    extend self

    def find_by_name(name)
      License.find_by_name(name.to_s).url
    end
  end
end
