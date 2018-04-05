module LicenseFinder
  class Mix < PackageManager
    def initialize(options = {})
      super
      @command = options[:mix_command] || Mix.package_management_command
      @deps_path = Pathname(options[:mix_deps_dir] || 'deps')
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
      'mix'
    end

    def self.prepare_command
      'mix deps.get'
    end

    def possible_package_paths
      [project_path.join('mix.exs')]
    end

    private

    def end_of_package_lines?(line)
      line == 'ok'
    end

    def mix_output
      command = "#{@command} deps"
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      packages_lines(stdout)
        .reject { |package_lines| package_lines.length == 1 } # in_umbrella: true dependencies
        .map { |package_lines| [package_lines[0].split(' ')[1], resolve_version(package_lines[1])] }
    end

    def packages_lines(stdout)
      packages_lines, last_package_lines =
        stdout
        .each_line
        .map(&:strip)
        .reject { |line| end_of_package_lines?(line) }
        .reduce([[], []]) do |(packages_lines, package_lines), line|
        if start_of_package_lines?(line)
          packages_lines.push(package_lines) unless package_lines.empty?

          [packages_lines, [line]]
        else
          package_lines.push(line)
          [packages_lines, package_lines]
        end
      end

      packages_lines.push(last_package_lines)
    end

    def resolve_version(line)
      line =~ /locked at ([^\s]+)/ ? Regexp.last_match(1) : line
    end

    def start_of_package_lines?(line)
      line.start_with?('* ')
    end
  end
end
