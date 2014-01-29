module LicenseFinder
  class BundlerGroup < Sequel::Model
    def self.named(name)
      find_or_create(name: name)
    end
  end
end
