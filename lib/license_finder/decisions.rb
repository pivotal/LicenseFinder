module LicenseFinder
  class Decisions
    def initialize
      @packages = {} # could be a Set if ManualPackage's were equal based on name/version
      @licenses = {}
      @approved = Set.new
      @whitelisted = Set.new
      @ignored = Set.new
      @ignored_groups = Set.new
    end

    def packages
      @packages.values
    end

    def add_package(name, version = nil)
      @packages[name.to_s] = ManualPackage.new(name, version)
      self
    end

    def remove_package(name)
      @packages.delete(name.to_s)
      self
    end

    def license(name, lic)
      @licenses[name.to_s] = License.find_by_name(lic)
      self
    end

    def approve(name)
      @approved << name.to_s
      self
    end

    def whitelist(lic)
      @whitelisted << License.find_by_name(lic)
      self
    end

    def unwhitelist(lic)
      @whitelisted.delete(License.find_by_name(lic))
      self
    end

    def ignore(name)
      @ignored << name.to_s
      self
    end

    def heed(name)
      @ignored.delete(name.to_s)
      self
    end

    def ignore_group(name)
      @ignored_groups << name.to_s
      self
    end

    def heed_group(name)
      @ignored_groups.delete(name.to_s)
      self
    end

    def license_of(name)
      @licenses[name.to_s]
    end

    def approved?(name)
      @approved.include?(name.to_s)
    end

    def approved_license?(lic)
      @whitelisted.include?(License.find_by_name(lic))
    end

    def ignored?(name)
      @ignored.include?(name.to_s)
    end

    def ignored_group?(name)
      @ignored_groups.include?(name.to_s)
    end
  end
end
