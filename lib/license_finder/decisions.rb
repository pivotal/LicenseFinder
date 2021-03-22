# frozen_string_literal: true

require 'open-uri'
require 'license_finder/license'

module LicenseFinder
  class Decisions
    ######
    # READ
    ######

    attr_reader :packages, :permitted, :restricted, :ignored, :ignored_groups, :project_name, :inherited_decisions

    def licenses_of(name)
      @licenses[name]
    end

    def homepage_of(name)
      @homepages[name]
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

    def permitted?(lic)
      if @permitted.include?(lic)
        true
      elsif lic.is_a?(OrLicense)
        lic.sub_licenses.any? { |sub_lic| @permitted.include?(sub_lic) }
      elsif lic.is_a?(AndLicense)
        lic.sub_licenses.all? { |sub_lic| @permitted.include?(sub_lic) }
      else
        false
      end
    end

    def restricted?(lic)
      @restricted.include?(lic)
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
      @homepages = {}
      @approvals = {}
      @permitted = Set.new
      @restricted = Set.new
      @ignored = Set.new
      @ignored_groups = Set.new
      @inherited_decisions = Set.new
    end

    def add_package(name, version, txn = {})
      add_decision [:add_package, name, version, txn]
      @packages << ManualPackage.new(name, version)
      self
    end

    def remove_package(name, txn = {})
      add_decision [:remove_package, name, txn]
      @packages.delete(ManualPackage.new(name))
      self
    end

    def license(name, lic, txn = {})
      add_decision [:license, name, lic, txn]
      @licenses[name] << License.find_by_name(lic)
      self
    end

    def unlicense(name, lic, txn = {})
      add_decision [:unlicense, name, lic, txn]
      @licenses[name].delete(License.find_by_name(lic))
      self
    end

    def homepage(name, homepage, txn = {})
      add_decision [:homepage, name, homepage, txn]
      @homepages[name] = homepage
      self
    end

    def approve(name, txn = {})
      add_decision [:approve, name, txn]

      versions = []
      versions = @approvals[name][:safe_versions] if @approvals.key?(name)
      @approvals[name] = TXN.from_hash(txn, versions)
      @approvals[name][:safe_versions].concat(txn[:versions]) unless txn[:versions].nil?
      self
    end

    def unapprove(name, txn = {})
      add_decision [:unapprove, name, txn]
      @approvals.delete(name)
      self
    end

    def permit(lic, txn = {})
      add_decision [:permit, lic, txn]
      @permitted << License.find_by_name(lic)
      self
    end

    def unpermit(lic, txn = {})
      add_decision [:unpermit, lic, txn]
      @permitted.delete(License.find_by_name(lic))
      self
    end

    def restrict(lic, txn = {})
      add_decision [:restrict, lic, txn]
      @restricted << License.find_by_name(lic)
      self
    end

    def unrestrict(lic, txn = {})
      add_decision [:unrestrict, lic, txn]
      @restricted.delete(License.find_by_name(lic))
      self
    end

    def ignore(name, txn = {})
      add_decision [:ignore, name, txn]
      @ignored << name
      self
    end

    def heed(name, txn = {})
      add_decision [:heed, name, txn]
      @ignored.delete(name)
      self
    end

    def ignore_group(name, txn = {})
      add_decision [:ignore_group, name, txn]
      @ignored_groups << name
      self
    end

    def heed_group(name, txn = {})
      add_decision [:heed_group, name, txn]
      @ignored_groups.delete(name)
      self
    end

    def name_project(name, txn = {})
      add_decision [:name_project, name, txn]
      @project_name = name
      self
    end

    def unname_project(txn = {})
      add_decision [:unname_project, txn]
      @project_name = nil
      self
    end

    def inherit_from(filepath_info)
      decisions =
        if filepath_info.is_a?(Hash)
          resolve_inheritance(filepath_info)
        elsif filepath_info =~ %r{^https?://}
          open_uri(filepath_info).read
        else
          Pathname(filepath_info).read
        end

      add_decision [:inherit_from, filepath_info]
      @inherited_decisions << filepath_info
      restore_inheritance(decisions)
    end

    def resolve_inheritance(filepath_info)
      if (gem_name = filepath_info['gem'])
        Pathname(gem_config_path(gem_name, filepath_info['path'])).read
      else
        open_uri(filepath_info['url'], filepath_info['authorization']).read
      end
    end

    def gem_config_path(gem_name, relative_config_path)
      spec = Gem::Specification.find_by_name(gem_name)
      File.join(spec.gem_dir, relative_config_path)
    rescue Gem::LoadError => e
      raise Gem::LoadError,
            "Unable to find gem #{gem_name}; is the gem installed? #{e}"
    end

    def remove_inheritance(filepath)
      @decisions -= [[:inherit_from, filepath]]
      @inherited_decisions.delete(filepath)
      self
    end

    def add_decision(decision)
      @decisions << decision unless @inherited
    end

    def restore_inheritance(decisions)
      @inherited = true
      self.class.restore(decisions, self)
      @inherited = false
      self
    end

    def open_uri(uri, auth = nil)
      header = {}
      auth_header = resolve_authorization(auth)
      header['Authorization'] = auth_header if auth_header

      # ruby < 2.5.0 URI.open is private
      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.5.0')
        # rubocop:disable Security/Open
        open(uri, header)
        # rubocop:enable Security/Open
      else
        URI.open(uri, header)
      end
    end

    def resolve_authorization(auth)
      return unless auth

      token_env = auth.match(/\$(\S.*)/)
      return auth unless token_env

      token = ENV[token_env[1]]
      auth.sub(token_env[0], token)
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

    def self.restore(persisted, result = new)
      return result unless persisted

      actions = YAML.load(persisted)

      list_of_actions = (actions || []).map(&:first)

      if (list_of_actions & %i[whitelist blacklist]).any?
        raise 'The decisions file seems to have whitelist/blacklist keys which are deprecated. Please replace them with permit/restrict respectively and try again! More info - https://github.com/pivotal/LicenseFinder/commit/a40b22fda11b3a0efbb3c0a021381534bc998dd9'
      end

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
