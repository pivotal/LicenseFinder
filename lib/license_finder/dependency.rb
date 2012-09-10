module LicenseFinder
  class Dependency
    attr_accessor :name, :version, :license, :approved, :license_url, :notes, :license_files, :readme_files, :source

    def self.from_hash(attrs)
      attrs['license_files'] = attrs['license_files'].map { |lf| lf['path'] } if attrs['license_files']
      attrs['readme_files'] = attrs['readme_files'].map { |rf| rf['path'] } if attrs['readme_files']

      new(attrs)
    end

    def initialize(attributes = {})
      @source = attributes['source']
      @name = attributes['name']
      @version = attributes['version']
      @license = attributes['license']
      @approved = attributes['approved'] || LicenseFinder.config.whitelist.include?(attributes['license'])
      @license_url = attributes['license_url'] || ''
      @notes = attributes['notes'] || ''
      @license_files = attributes['license_files'] || []
      @readme_files = attributes['readme_files'] || []
    end

    def to_yaml_entry
      attrs = "- name: \"#{name}\"\n  version: \"#{version}\"\n  license: \"#{license}\"\n  approved: #{approved}\n  source: \"#{source}\"\n  license_url: \"#{license_url}\"\n  notes: \"#{notes}\"\n"
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
      if license == 'other'
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
      end

      str
    end
  end
end

