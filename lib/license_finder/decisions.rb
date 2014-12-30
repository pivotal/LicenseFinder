module LicenseFinder
  class Decisions
    ######
    # READ
    ######

    attr_reader :packages, :whitelisted, :ignored, :ignored_groups, :project_name

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

    #######
    # WRITE
    #######

    TXN = Struct.new(:who, :why, :safe_when) do
      def self.from_hash(txn)
        new(txn[:who], txn[:why], txn[:when])
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

    def add_package(name, version, txn = {})
      @decisions << [:add_package, name, version, txn]
      @packages << ManualPackage.new(name, version)
      self
    end

    def remove_package(name, txn = {})
      @decisions << [:remove_package, name, txn]
      @packages.delete(ManualPackage.new(name))
      self
    end

    def license(name, lic, txn = {})
      @decisions << [:license, name, lic, txn]
      @licenses[name] = License.find_by_name(lic)
      self
    end

    def unlicense(name, txn= {})
      @decisions << [:unlicense, name, txn]
      @licenses.delete(name)
      self
    end

    def approve(name, txn = {})
      @decisions << [:approve, name, txn]
      @approvals[name] = TXN.from_hash(txn)
      self
    end

    def unapprove(name, txn = {})
      @decisions << [:unapprove, name, txn]
      @approvals.delete(name)
      self
    end

    def whitelist(lic, txn = {})
      @decisions << [:whitelist, lic, txn]
      @whitelisted << License.find_by_name(lic)
      self
    end

    def unwhitelist(lic, txn = {})
      @decisions << [:unwhitelist, lic, txn]
      @whitelisted.delete(License.find_by_name(lic))
      self
    end

    def ignore(name, txn = {})
      @decisions << [:ignore, name, txn]
      @ignored << name
      self
    end

    def heed(name, txn = {})
      @decisions << [:heed, name, txn]
      @ignored.delete(name)
      self
    end

    def ignore_group(name, txn = {})
      @decisions << [:ignore_group, name, txn]
      @ignored_groups << name
      self
    end

    def heed_group(name, txn = {})
      @decisions << [:heed_group, name, txn]
      @ignored_groups.delete(name)
      self
    end

    def name_project(name, txn = {})
      @decisions << [:name_project, name, txn]
      @project_name = name
      self
    end

    def unname_project(txn = {})
      @decisions << [:unname_project, txn]
      @project_name = nil
      self
    end

    #########
    # PERSIST
    #########

    def self.saved!
      restore(read!)
    end

    def save!
      write!(persist)
    end

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

    def self.read!
      file = LicenseFinder.config.artifacts.decisions_file
      file.read if file.exist?
    end

    def write!(value)
      LicenseFinder.config.artifacts.decisions_file.open('w+') do |f|
        f.print value
      end
    end
  end
end
