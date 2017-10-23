module LicenseFinder
  class Mix < PackageManager
    def initialize(options={})
      super
      @command = options[:mix_command] || Mix::package_management_command
      @deps_path = Pathname(options[:mix_deps_dir] || "deps")
    end

    def current_packages
      mix_output.map do |name, version|
        MixPackage.new(
          name,
          version,
          install_path: @deps_path.join(name),
          logger: logger
        )
      end
    end

    def self.package_management_command
      "mix"
    end

    private

    def mix_output
      command = "#{@command} deps"
      stdout, stderr, exitstatus = Dir.chdir(project_path) { capture(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless exitstatus == 0

      stdout
        .each_line
        .map(&:strip)
        .select { |line| line_of_interest? line }
        .each_slice(2).to_a
        .map { |line1, line2| [ line1.split(" ")[1], resolve_version(line2) ] }
    end

    def line_of_interest?(line)
      line.start_with?("* ") ||
        line.start_with?("locked at") ||
        line.start_with?("the dependency is not available")
    end

    def resolve_version(line)
      line =~ /locked at ([^\s]+)/ ? $1 : line
    end

    def possible_package_paths
      [project_path.join('mix.exs')]
    end
  end
end
