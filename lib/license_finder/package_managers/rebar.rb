# frozen_string_literal: true

module LicenseFinder
  class Rebar < PackageManager
    def initialize(options = {})
      super
      @command = options[:rebar_command] || package_management_command
      @deps_path = Pathname(options[:rebar_deps_dir] || File.join(project_path, '_build/default/lib'))
    end

    def current_packages
      rebar_deps.map do |name, version|
        licenses, homepage = dep_info(name)
        RebarPackage.new(
          name,
          version,
          install_path: @deps_path.join(name),
          homepage: homepage,
          spec_licenses: licenses.nil? ? [] : [licenses],
          logger: logger
        )
      end
    end

    def package_management_command
      'rebar3'
    end

    def possible_package_paths
      [project_path.join('rebar.config')]
    end

    private

    def rebar_deps
      command = "#{@command} tree"
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      stdout
        .each_line
        .reject { |line| line.start_with?('=') || line.include?('project app') }
        .map do |line|
          matches = line.match(/(?<name>\w+)─(?<version>[\S.]+)\s*/)
          [matches[:name], matches[:version]] if matches
        end.compact
    end

    def dep_info(name)
      command = "#{@command} pkgs #{name}"
      stdout, _, status = Cmd.run(command)
      return [nil, nil] unless status.success?

      licenses = nil
      homepage = nil

      stdout.scan(/Licenses: (?<licenses>.+)|(?<homepage>(https|http).*)/) do |pkg_licenses, pkg_homepage|
        licenses ||= pkg_licenses
        homepage ||= pkg_homepage
      end

      [licenses, homepage]
    end
  end
end
