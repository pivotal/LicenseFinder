# frozen_string_literal: true

module LicenseFinder
  class ManualLicenses
    def initialize
      @all_versions = {}
      @specific_versions = {}
    end

    def licenses_of(name, version = nil)
      return @all_versions[name] if @all_versions[name]

      if version && @specific_versions[name] && @specific_versions[name][version]
        @specific_versions[name][version]
      else
        Set.new
      end
    end

    def assign_to_all_versions(name, lic)
      # Ex: licenses add foo_gem MIT => Adds MIT at "all" versions for this gem

      @all_versions[name] ||= Set.new
      @all_versions[name] << to_license(lic)

      @specific_versions.delete(name)
    end

    def assign_to_specific_versions(name, lic, versions)
      # Ex: licenses add foo_gem MIT --version=1.0 => Adds MIT at only 1.0 for this gem

      @specific_versions[name] ||= {}
      versions.each do |version|
        @specific_versions[name][version] ||= Set.new
        @specific_versions[name][version] << to_license(lic)
      end

      @all_versions.delete(name)
    end

    def unassign_from_all_versions(name, lic = nil)
      if lic
        # Ex: licenses remove foo_gem MIT => Removes MIT at all versions for this gem
        @all_versions[name]&.delete(to_license(lic))

        @specific_versions[name]&.each do |_version, licenses|
          licenses.delete(to_license(lic))
        end
      else
        # Ex: licenses remove foo_gem => Removes all licenses for all versions of the gem
        @all_versions.delete(name)
        @specific_versions.delete(name)
      end
    end

    def unassign_from_specific_versions(name, lic, versions)
      return unless @specific_versions[name]

      versions.each do |version|
        if @specific_versions[name][version]
          if lic
            # Ex: licenses remove foo_gem MIT --version=1.0 => Removes MIT at only 1.0 for this gem
            @specific_versions[name][version].delete(to_license(lic))
            @specific_versions[name].delete(version) if @specific_versions[name][version].empty?
          else
            # Ex: licenses remove foo_gem --version=1.0 => Removes all licenses at only 1.0 for the gem
            @specific_versions[name].delete(version)
          end
        end
      end
    end

    private

    def to_license(lic)
      License.find_by_name(lic)
    end
  end
end
