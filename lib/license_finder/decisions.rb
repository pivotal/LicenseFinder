require 'yaml'

module LicenseFinder
  class Decisions
    #########
    # PERSIST
    #########

    def self.restore(persisted)
      result = new
      if persisted
        YAML.load(persisted).each do |action, *args|
          result.send(action, *args)
        end
      end
      result
    end

    def persist
      YAML.dump(@decisions)
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
      file.read if file.exist?
    end

    #######
    # WRITE
    #######

    TXN = Struct.new(:who, :why, :unsafe_when) do
      def self.from_txn(txn)
        new(txn[:who], txn[:why], txn[:when])
      end

      def safe_when
        if unsafe_when.is_a?(String)
          Time.parse(unsafe_when)
        else
          unsafe_when
        end
      end
    end

    def initialize
      @decisions = []
      @packages = Set.new
      @licenses = {}
      @approvals = {}
      @whitelisted = Set.new
      @ignored = Set.new
      @ignored_groups = Set.new
    end

    def add_package(name, version)
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

    def approve(name, txn = {})
      @decisions << [:approve, name, txn]
      @approvals[name] = TXN.from_txn(txn)
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

    def approval_of(name)
      @approvals[name]
    end

    def approved?(name)
      @approvals.has_key?(name)
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
