module LicenseFinder
  class Dependency

    attr_reader :name, :version, :license, :approved, :license_url, :notes, :license_files, :readme_files

    def self.from_hash(attrs)
      lfs = attrs['license_files'] ? attrs['license_files'].map { |lf| lf['path'] } : []
      rfs = attrs['readme_files'] ? attrs['readme_files'].map { |rf| rf['path'] } : []
      new(attrs['name'], attrs['version'], attrs['license'], attrs['approved'], attrs['license_url'], attrs['notes'], lfs, rfs)
    end

    def initialize(name, version, license, approved, license_url = '', notes = '', license_files = [], readme_files = [])
      @name = name
      @version = version
      @license = license
      @approved = approved
      @license_url = license_url
      @notes = notes
      @license_files = license_files
      @readme_files = readme_files
    end

    def to_yaml_entry
      attrs = "- name: \"#{name}\"\n  version: \"#{version}\"\n  license: \"#{license}\"\n  approved: #{approved}\n  license_url: \"#{license_url}\"\n  notes: \"#{notes}\"\n"
      attrs << "  license_files:\n"
      if !self.license_files.empty?
        self.license_files.each do |lf|
          attrs << "  - path: \"#{lf}\"\n"
        end
      end
      attrs << "  readme_files:\n"
      if !self.readme_files.empty?
        self.readme_files.each do |rf|
          attrs << "  - path: \"#{rf}\"\n"
        end
      end
      attrs
    end

    def to_s
      url = ", #{license_url}" if license_url != ''
      str = "#{name} #{version}, #{license}#{url}"
      str << "\n  license files:"
      unless self.license_files.empty?
        self.license_files.each do |lf|
          str << "\n    #{lf}"
        end
      end
      str << "\n  readme files:"
      unless self.readme_files.empty?
        self.readme_files.each do |lf|
          str << "\n    #{lf}"
        end
      end

      str
    end

  end
end

