module LicenseFinder
  class Rebar < PackageManager
    def initialize(options={})
      super
      @command = options[:rebar_command] || "rebar"
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
      output, success = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{output}" unless success

      output
        .each_line
        .reject { |line| line.start_with?("=") }
        .map { |line| line.split(" ") }
    end

    def package_path
      project_path.join('rebar.config')
    end
  end
end
