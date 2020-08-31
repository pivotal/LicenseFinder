# frozen_string_literal: true

require 'iniparse'

module LicenseFinder
  class GitSubmodule < PackageManager
    def initialize(options = {})
      super
      @git_submodule_status = {}
    end

    def current_packages
      update_git_submodule_status
      find_packages(project_path).flatten!
    end

    def package_management_command
      'git'
    end

    def prepare_command
      'git submodule upgrade --init --recursive'
    end

    def possible_package_paths
      [project_path.join('.gitmodules')]
    end

    private

    # we have to recurse ourselves, as the .gitmodules are per path (while the status would contain everything)
    def find_packages(path)
      dotgitmodules_file_path = path.join('.gitmodules')
      return [] unless File.exist?(dotgitmodules_file_path)

      dotgitmodules = IniParse.parse(File.read(dotgitmodules_file_path))
      dotgitmodules.collect do |section|
        name = section.key.split('"')[1]
        [
          GitSubmodulePackage.new(name,
                                  @git_submodule_status[path.join(name).relative_path_from(project_path).to_s],
                                  path.join(section['path']), section['url'])
        ] + find_packages(path.join(section['path']))
      end
    end

    def status_command
      'git submodule status --recursive'
    end

    def update_git_submodule_status
      stdout, stderr, status = Dir.chdir(project_path) { Cmd.run(status_command) }
      raise "Command '#{command}' failed to execute: #{stderr}" if !status.success? && status.exitstatus != 1

      stdout.split("\n").each do |gitmodule_line|
        _commit, name, version = gitmodule_line.split(' ')
        @git_submodule_status[name] = version[1..-2] # trims '(' and ')''
      end
    end
  end
end
