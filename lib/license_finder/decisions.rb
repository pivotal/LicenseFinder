module LicenseFinder
  class Decisions
    ######
    # READ
    ######

    attr_reader :packages, :whitelisted, :blacklisted, :ignored, :ignored_groups, :project_name

    def licenses_of(name)
      @licenses[name]
    end

    def approval_of(name, version = nil)
      if !@approvals.key?(name)
        nil
      elsif !version.nil?
        @approvals[name] if @approvals[name][:safe_versions].empty? || @approvals[name][:safe_versions].include?(version)
      elsif @approvals[name][:safe_versions].empty?
        @approvals[name]
      end
    end

    def approved?(name, version = nil)
      if !@approvals.key?(name)
        nil
      elsif !version.nil?
        @approvals.key?(name) && @approvals[name][:safe_versions].empty? || @approvals[name][:safe_versions].include?(version)
      else
        @approvals.key?(name)
      end
    end

    def whitelisted?(lic)
      @whitelisted.include?(lic)
    end

    def blacklisted?(lic)
      @blacklisted.include?(lic)
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

    TXN = Struct.new(:who, :why, :safe_when, :safe_versions) do
      def self.from_hash(txn, versions)
        new(txn[:who], txn[:why], txn[:when], versions || [])
      end
    end

    def initialize
      @decisions = []
      @packages = Set.new
      @licenses = Hash.new { |h, k| h[k] = Set.new }
      @approvals = {}
      @whitelisted = Set.new
      @blacklisted = Set.new
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
      @licenses[name] << License.find_by_name(lic)
      self
    end

    def unlicense(name, lic, txn = {})
      @decisions << [:unlicense, name, lic, txn]
      @licenses[name].delete(License.find_by_name(lic))
      self
    end

    def approve(name, txn = {})
      @decisions << [:approve, name, txn]

      versions = []
      versions = @approvals[name][:safe_versions] if @approvals.key?(name)
      @approvals[name] = TXN.from_hash(txn, versions)
      @approvals[name][:safe_versions].concat(txn[:versions]) unless txn[:versions].nil?
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

    def blacklist(lic, txn = {})
      @decisions << [:blacklist, lic, txn]
      @blacklisted << License.find_by_name(lic)
      self
    end

    def unblacklist(lic, txn = {})
      @decisions << [:unblacklist, lic, txn]
      @blacklisted.delete(License.find_by_name(lic))
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

    def self.fetch_saved(file)
      restore(read!(file))
    end

    def save!(file)
      write!(persist, file)
    end

    def self.restore(persisted)
      result = new
      return result unless persisted

      actions = YAML.load(persisted)
      (actions || []).each do |action, *args|
        result.send(action, *args)
      end
      result
    end

    def persist
      YAML.dump(@decisions)
    end

    def self.read!(file)
      file.read if file.exist?
    end

    def write!(value, file)
      file.dirname.mkpath
      file.open('w+') do |f|
        f.print value
      end
    end
  end
end
