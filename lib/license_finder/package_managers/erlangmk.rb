# frozen_string_literal: true

module LicenseFinder
  class Erlangmk < PackageManager
    def package_management_command
      "make --directory=#{project_path} --no-print-directory"
    end

    def prepare_command
      "#{package_management_command} deps"
    end

    def possible_package_paths
      [
        project_path.join('Erlang.mk'),
        project_path.join('erlang.mk')
      ]
    end

    def current_packages
      show_deps.map do |dep|
        ErlangmkPackage.new_from_show_dep(dep)
      end
    end

    private

    def show_deps
      command = "#{package_management_command} show-deps"
      stdout, stderr, status = Cmd.run(command)
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      stdout.each_line.map(&:strip)
    end
  end
end
