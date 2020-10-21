# frozen_string_literal: true

module LicenseFinder
  class Mix < PackageManager
    def initialize(options = {})
      super
      @command = options[:mix_command] || package_management_command
      @elixir_command = options[:elixir_command] || 'elixir'
      @deps_path = Pathname(options[:mix_deps_dir] || 'deps')
    end

    def current_packages
      mix_output.map do |name, version|
        MixPackage.new(
          name,
          version,
          install_path: @deps_path.join(name),
          logger: logger,
          spec_licenses: licenses(name)
        )
      end
    end

    def licenses(name)
      licenses_by_package = load_all_licenses
      licenses_by_package.fetch(name, ['license is not in deps'])
    end

    def package_management_command
      'mix'
    end

    def self.package_lock_file
      'mix.lock'
    end

    def prepare_command
      'mix deps.get'
    end

    def possible_package_paths
      [project_path.join('mix.exs')]
    end

    def installed?(logger = Core.default_logger)
      if package_management_command.nil?
        logger.debug self.class, 'no command defined'
        true
      elsif command_exists?('elixir') && command_exists?('mix')
        logger.debug self.class, 'is installed', color: :green
        true
      else
        logger.info self.class, '(elixir) is not installed', color: :red
        false
      end
    end

    private

    def load_all_licenses
      elixir_code = <<-ELIXIR
      deps_path = "#{@deps_path}"

      case File.ls(deps_path) do
        {:ok, dirs} ->
          Enum.reduce(dirs, [], fn name, acc ->
            with hexmetadata_file <- Path.join([deps_path, name, "hex_metadata.config"]),
                {:ok, metadata} <- :file.consult(hexmetadata_file),
                {"licenses", licenses} <- List.keyfind(metadata, "licenses", 0) do
              [[name, licenses] | acc]
            else
              _ -> acc
            end
          end)
        {:error, _} ->
          []
      end
      |> IO.inspect(limit: :infinity)
      ELIXIR
      command = "#{@elixir_command} -e '#{elixir_code}'"
      return {} unless File.directory?(project_path)

      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      Hash[JSON.parse(stdout)]
    end

    def end_of_package_lines?(line)
      line == 'ok'
    end

    def mix_output
      command = "#{@command} deps"
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(command) }
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      packages_lines(stdout)
        .reject { |package_lines| package_lines.length == 1 || package_lines.empty? } # in_umbrella: true dependencies
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
