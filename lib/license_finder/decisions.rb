require 'csv'

module LicenseFinder
  class Decisions
    #########
    # PERSIST
    #########

    def self.restore(persisted)
      result = new
      CSV.parse(persisted).each do |action, *args|
        result.send(action, *args)
      end
      result
    end

    def persist
      CSV.generate do |csv|
        @decisions.each do |decision|
          csv << decision
        end
      end
    end

    def self.saved!
      restore(read)
    end

    def save!
      write(persist)
    end

    def write(value)
      LicenseFinder.config.artifacts.decisions_file.open('w+') do |f|
        f.puts value
      end
    end

    def self.read
      file = LicenseFinder.config.artifacts.decisions_file
      if file.exist?
        file.read
      else
        ""
      end
    end

    #######
    # WRITE
    #######

    def initialize
      @decisions = []
      @packages = Set.new
      @licenses = {}
      @approved = Set.new
      @whitelisted = Set.new
      @ignored = Set.new
      @ignored_groups = Set.new
    end

    def add_package(name, version = nil)
      @decisions << [:add_package, name, version]
      @packages << ManualPackage.new(name, version)
      self
    end

    def remove_package(name)
      @decisions << [:remove_package, name]
      @packages.delete(ManualPackage.new(name))
      self
    end

    def license(name, lic)
      @decisions << [:license, name, lic]
      @licenses[name] = License.find_by_name(lic)
      self
    end

    def approve(name)
      @decisions << [:approve, name]
      @approved << name
      self
    end

    def whitelist(lic)
      @decisions << [:whitelist, lic]
      @whitelisted << License.find_by_name(lic)
      self
    end

    def unwhitelist(lic)
      @decisions << [:unwhitelist, lic]
      @whitelisted.delete(License.find_by_name(lic))
      self
    end

    def ignore(name)
      @decisions << [:ignore, name]
      @ignored << name
      self
    end

    def heed(name)
      @decisions << [:heed, name]
      @ignored.delete(name)
      self
    end

    def ignore_group(name)
      @decisions << [:ignore_group, name]
      @ignored_groups << name
      self
    end

    def heed_group(name)
      @decisions << [:heed_group, name]
      @ignored_groups.delete(name)
      self
    end

    ######
    # READ
    ######

    attr_reader :packages, :whitelisted, :ignored, :ignored_groups

    def license_of(name)
      @licenses[name]
    end

    def approved?(name)
      @approved.include?(name)
    end

    def approved_license?(lic)
      @whitelisted.include?(lic)
    end

    def ignored?(name)
      @ignored.include?(name)
    end

    def ignored_group?(name)
      @ignored_groups.include?(name)
    end
  end
end
