module LicenseFinder
  class Rebar < PackageManager
    def initialize(options={})
      super
      @command = options[:rebar_command] || Rebar::package_management_command
      @deps_path = Pathname(options[:rebar_deps_dir] || "deps")
    end

    def current_packages
      rebar_ouput.map do |name, version_type, version_value, homepage|
        RebarPackage.new(
          name,
          "#{version_type}: #{version_value}",
          install_path: @deps_path.join(name),
          homepage: homepage,
          logger: logger
        )
      end
    end

    def self.package_management_command
      "rebar"
    end

    private

    def rebar_ouput
      command = "#{@command} list-deps"
      stdout, stderr, exitstatus = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless exitstatus == 0

      stdout
        .each_line
        .reject { |line| line.start_with?("=") }
        .map { |line| line.split(" ") }
    end

    def possible_package_paths
      [project_path.join('rebar.config')]
    end
  end
end
