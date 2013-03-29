module LicenseFinder
  class Dependency < LicenseFinder::Persistence::Dependency
    def approved
      self.approved = !!(config.whitelisted?(license) || super)
    end

    def license_files
      super || (self.license_files = [])
    end

    def bundler_groups
      super || (self.bundler_groups = [])
    end

    def children
      super || (self.children = [])
    end

    def parents
      super || (self.parents = [])
    end

    def approve!
      self.approved = true
      save
    end

    def approved?
      !!approved
    end

    def license_url
      LicenseFinder::LicenseUrl.find_by_name license
    end

    def merge(other)
      raise "Cannot merge dependencies with different names. Expected #{name}, was #{other.name}." unless other.name == name

      new_attributes = other.attributes.merge("notes" => notes)

      if other.license == license || other.license == 'other'
        new_attributes["approved"] = approved
        new_attributes["license"]  = license
      else
        new_attributes["approved"] = nil
      end

      update_attributes new_attributes

      self
    end

    def set_license_manually(license)
      update_attributes('license' => license, 'manual' => true)
    end

    private

    def config
      LicenseFinder.config
    end
  end
end

