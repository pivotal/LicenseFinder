# frozen_string_literal: true

require 'json'

module LicenseFinder
  class Conda < PackageManager
    attr_reader :conda_bash_setup_script

    def initialize(options = {})
      @conda_bash_setup_script = options[:conda_bash_setup_script] || Pathname("#{ENV['HOME']}/miniconda3/etc/profile.d/conda.sh")
      super
    end

    # This command is *not* directly executable. See .conda() below.
    def prepare_command
      "conda env create -f #{detected_package_path}"
    end

    def prepare
      return if environment_exists?

      prep_cmd = prepare_command
      _stdout, stderr, status = Dir.chdir(project_path) { conda(prep_cmd) }
      return if status.success?

      log_errors stderr
      raise "Prepare command '#{prep_cmd}' failed" unless @prepare_no_fail
    end

    def current_packages
      conda_list.map do |entry|
        case entry['channel']
        when 'pypi'
          # PyPI is much faster than `conda search`, use it when we can.
          PipPackage.new(entry['name'], entry['version'], PyPI.definition(entry['name'], entry['version']))
        else
          CondaPackage.new(conda_search_info(entry))
        end
      end.compact
    end

    def possible_package_paths
      [project_path.join('environment.yaml'), project_path.join('environment.yml')]
    end

    private

    def environment_exists?
      environments.grep(environment_name).any?
    end

    def environments
      command = 'conda env list'
      stdout, stderr, status = conda command

      environments = []
      if status.success?
        environments = stdout.split("\n").grep_v(/^#/).map { |line| line.split.first }
      else
        log_errors_with_cmd command, stderr
      end
      environments
    end

    def environment_file
      detected_package_path
    end

    def environment_name
      @environment_name ||= YAML.load_file(environment_file).fetch('name')
    end

    def conda(command)
      Open3.capture3('bash', '-c', "source #{conda_bash_setup_script} && #{command}")
    end

    def activated_conda(command)
      Open3.capture3('bash', '-c', "source #{conda_bash_setup_script} && conda activate #{environment_name} && #{command}")
    end

    # Algorithm is based on
    # https://bioinformatics.stackexchange.com/a/11226
    # but completely recoded in Ruby. Like the poster, if the package is
    # actually managed by conda, we assume that all the potential infos (for
    # various architectures, versions of python, etc) have the same license.
    def conda_list
      command = 'conda list'
      stdout, stderr, status = activated_conda(command)

      if status.success?
        conda_list = []
        stdout.each_line do |line|
          next if line =~ /^\s*#/

          name, version, build, channel = line.split
          conda_list << {
            'name' => name,
            'version' => version,
            'build' => build,
            'channel' => channel
          }
        end
        conda_list
      else
        log_errors_with_cmd command, stderr
        []
      end
    end

    def conda_search_info(list_entry)
      command = 'conda search --info --json '
      command += "--channel #{list_entry['channel']} " if list_entry['channel'] && !list_entry['channel'].empty?
      command += "'#{list_entry['name']} #{list_entry['version']}'"

      # Errors from conda (in --json mode, at least) show up in stdout, not stderr
      stdout, _stderr, status = activated_conda(command)

      name = list_entry['name']

      if status.success?
        JSON(stdout).fetch(name).first
      else
        log_errors_with_cmd command, stdout
        list_entry
      end
    rescue KeyError
      logger.info('Conda', "Key error trying to find #{name} in\n#{JSON(stdout)}")
      list_entry
    end
  end
end
