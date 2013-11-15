module LicenseFinder
  class LicenseAlias < Sequel::Model
    def self.named(name)
      find_or_create(name: name)
    end

    def initialize(*args)
      super
      self.url = LicenseUrl.find_by_name name
    end

    def whitelisted?
      !!(config.whitelisted?(name))
    end

    private

    def config
      LicenseFinder.config
    end
  end
end
