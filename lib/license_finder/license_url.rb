module LicenseFinder::LicenseUrl
  extend self

  def find_by_name(name)
    return unless name.respond_to?(:downcase)

    license = LicenseFinder::License.all.detect {|l| l.names.map(&:downcase).include? name.downcase }
    license.license_url if license
  end
end
