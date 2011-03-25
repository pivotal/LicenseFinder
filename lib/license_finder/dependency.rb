module LicenseFinder
  class Dependency

    attr_reader :name, :version, :license, :approved, :license_url, :notes

    def self.from_hash(attrs)
      new(attrs['name'], attrs['version'], attrs['license'], attrs['approved'], attrs['license_url'], attrs['notes'])
    end

    def initialize(name, version, license, approved, license_url = '', notes = '')
      @name = name
      @version = version
      @license = license
      @approved = approved
      @license_url = license_url
      @notes = notes
    end

    def to_yaml_entry
      "- name: \"#{name}\"\n  version: \"#{version}\"\n  license: \"#{license}\"\n  approved: #{approved}\n  license_url: \"#{license_url}\"\n  notes: \"#{notes}\"\n"
    end

    def to_s
      url = ", #{license_url}" if license_url != ''
      "#{name} #{version}, #{license}#{url}"
    end

  end
end

