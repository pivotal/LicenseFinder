# frozen_string_literal: true

module LicenseFinder
  class Erlangmk < PackageManager
    def package_management_command
      'make'
    end

    def package_management_command_with_path
      "#{package_management_command} --directory=#{project_path} --no-print-directory"
    end

    def prepare_command
      "#{package_management_command_with_path} fetch-deps"
    end

    def possible_package_paths
      [
        project_path.join('Erlang.mk'),
        project_path.join('erlang.mk')
      ]
    end

    def current_packages
      deps.map do |dep|
        ErlangmkPackage.new(dep)
      end
    end

    private

    def deps
      command = "#{package_management_command_with_path} QUERY='name fetch_method repo version absolute_path' query-deps"
      stdout, stderr, status = Cmd.run(command)
      raise "Command '#{command}' failed to execute: #{stderr}" unless status.success?

      dep_re = Regexp.new('^\s*DEP')
      line_re = Regexp.new('^[_a-z0-9]+:')

      stdout.each_line.map(&:strip).select { |line| !(line.start_with?('make') || line =~ dep_re) && line =~ line_re }
    end
  end
end
