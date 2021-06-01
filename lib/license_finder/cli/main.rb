# frozen_string_literal: true

require 'license_finder/report'
require 'license_finder/version'
require 'license_finder/diff'
require 'license_finder/package_delta'
require 'license_finder/license_aggregator'
require 'license_finder/project_finder'
require 'license_finder/logger'

module LicenseFinder
  module CLI
    class Main < Base
      extend Rootcommand

      FORMATS = {
        'text' => TextReport,
        'html' => HtmlReport,
        'markdown' => MarkdownReport,
        'csv' => CsvReport,
        'xml' => XmlReport,
        'json' => JsonReport,
        'junit' => JunitReport
      }.freeze

      class_option :go_full_version, desc: 'Whether dependency version should include full version. Only meaningful if used with a Go project. Defaults to false.'
      class_option :gradle_include_groups, desc: 'Whether dependency name should include group id. Only meaningful if used with a Java/gradle project. Defaults to false.'
      class_option :gradle_command,
                   desc: "Command to use when fetching gradle packages. Only meaningful if used with a Java/gradle project.
                          Defaults to 'gradlew' / 'gradlew.bat' if the wrapper is present, otherwise to 'gradle'."
      class_option :maven_include_groups, desc: 'Whether dependency name should include group id. Only meaningful if used with a Java/maven project. Defaults to false.'
      class_option :maven_options, desc: 'Maven options to append to command. Defaults to empty.'
      class_option :npm_options, desc: 'npm options to append to command. Defaults to empty.'
      class_option :pip_requirements_path, desc: 'Path to python requirements file. Defaults to requirements.txt.'
      class_option :python_version, desc: 'Python version to invoke pip with. Valid versions: 2 or 3. Default: 2'
      class_option :rebar_command, desc: "Command to use when fetching rebar packages. Only meaningful if used with a Erlang/rebar project. Defaults to 'rebar'."
      class_option :rebar_deps_dir, desc: "Path to rebar dependencies directory. Only meaningful if used with a Erlang/rebar project. Defaults to 'deps'."
      class_option :elixir_command, desc: "Command to use when parsing package metadata for Mix. Only meaningful if used with a Mix project (i.e., Elixir or Erlang). Defaults to 'elixir'."
      class_option :mix_command, desc: "Command to use when fetching packages through Mix. Only meaningful if used with a Mix project (i.e., Elixir or Erlang). Defaults to 'mix'."
      class_option :mix_deps_dir, desc: "Path to Mix dependencies directory. Only meaningful if used with a Mix project (i.e., Elixir or Erlang). Defaults to 'deps'."
      class_option :sbt_include_groups, desc: 'Whether dependency name should include group id. Only meaningful if used with a Scala/sbt project. Defaults to false.'
      class_option :conda_bash_setup_script, desc: "Path to conda.sh script. Only meaningful if used with a Conda project. Defaults to '~/miniconda3/etc/profile.d/conda.sh'."
      class_option :composer_check_require_only,
                   desc: "Whether to only check for licenses from dependencies on the 'require' section. Only meaningful if used with a Composer project. Defaults to false."

      # Method options which are shared between report and action_item
      def self.format_option
        method_option :format,
                      desc: 'Emit detailed info about what LicenseFinder is doing',
                      default: 'text',
                      enum: FORMATS.keys
      end

      def self.shared_options
        method_option :debug,
                      aliases: '-d',
                      type: :boolean,
                      desc: 'Emit detailed info about what LicenseFinder is doing'

        method_option :prepare,
                      aliases: '-p',
                      type: :boolean,
                      desc: 'Prepares the project first for license_finder',
                      default: false,
                      required: false

        method_option :prepare_no_fail,
                      type: :boolean,
                      desc: 'Prepares the project first for license_finder but carries on despite any potential failures',
                      default: false,
                      required: false

        method_option :recursive,
                      aliases: '-r',
                      type: :boolean,
                      default: false,
                      desc: 'Recursively runs License Finder on all sub-projects'

        method_option :aggregate_paths,
                      aliases: '-a',
                      type: :array,
                      desc: "Generate a single report for multiple projects. Ex: --aggregate_paths='path/to/project1' 'path/to/project2'"

        method_option :quiet,
                      aliases: '-q',
                      type: :boolean,
                      desc: 'Silences progress report',
                      required: false

        method_option :columns,
                      desc: "For text or CSV reports, which columns to print. Pick from: #{CsvReport::AVAILABLE_COLUMNS}",
                      type: :array
      end

      desc 'project_roots', 'List project directories to be scanned'
      shared_options
      def project_roots
        config.strict_matching = true
        project_path = config.project_path.to_s || Pathname.pwd.to_s
        paths = aggregate_paths
        filtered_project_roots = Scanner.remove_subprojects(paths)

        filtered_project_roots << project_path if aggregate_paths.include?(project_path) && !filtered_project_roots.include?(project_path)

        say(filtered_project_roots)
      end

      desc 'action_items', 'List unapproved dependencies (the default action for `license_finder`)'
      shared_options
      format_option
      def action_items
        finder = LicenseAggregator.new(config, aggregate_paths)
        any_packages = finder.any_packages?
        unapproved = finder.unapproved
        restricted = finder.restricted

        # Ensure to start output on a new line even with dot progress indicators.
        say "\n"

        unless any_packages
          say 'No dependencies recognized!', :red
          exit 0
        end

        if unapproved.empty?
          say 'All dependencies are approved for use', :green
        else
          unless restricted.empty?
            say 'Restricted dependencies:', :red
            say report_of(restricted)
          end

          other_unapproved = unapproved - restricted
          unless other_unapproved.empty?
            say 'Dependencies that need approval:', :yellow
            say report_of(other_unapproved)
          end

          exit 1
        end
      end

      default_task :action_items

      desc 'report', "Print a report of the project's dependencies to stdout"
      shared_options
      format_option
      method_option :write_headers, type: :boolean, desc: 'Write exported columns as header row (csv).', default: false, required: false
      method_option :save, desc: "Save report to a file. Default: 'license_report.csv' in project root.", lazy_default: 'license_report'

      def report
        finder = LicenseAggregator.new(config, aggregate_paths)
        report = report_of(finder.dependencies)
        save? ? save_report(report, config.save_file) : say(report)
      end

      desc 'version', 'Print the version of LicenseFinder'
      def version
        puts LicenseFinder::VERSION
      end

      desc 'diff OLDFILE NEWFILE', 'Command to view the differences between two generated reports (csv).'
      format_option
      method_option :save, desc: "Save report to a file. Default: 'license_report.csv' in project root.", lazy_default: 'license_report'
      def diff(file1, file2)
        f1 = IO.read(file1)
        f2 = IO.read(file2)
        report = DiffReport.new(Diff.compare(f1, f2))
        save? ? save_report(report, config.save_file) : say(report)
      end

      subcommand 'dependencies', Dependencies, 'Add or remove dependencies that your package managers are not aware of'
      subcommand 'licenses', Licenses, "Set a dependency's licenses, if the licenses found by license_finder are missing or wrong"
      subcommand 'approvals', Approvals, 'Manually approve dependencies, even if their licenses are not permitted'
      subcommand 'ignored_groups', IgnoredGroups, 'Exclude test and development dependencies from action items and reports'
      subcommand 'ignored_dependencies', IgnoredDependencies, 'Exclude individual dependencies from action items and reports'
      subcommand 'permitted_licenses', PermittedLicenses, 'Automatically approve any dependency that has a permitted license'
      subcommand 'restricted_licenses', RestrictedLicenses, 'Forbid approval of any dependency whose licenses are all restricted'
      subcommand 'project_name', ProjectName, 'Set the project name, for display in reports'
      subcommand 'inherited_decisions', InheritedDecisions, 'Add or remove decision files you want to inherit from'

      private

      def check_valid_project_path
        raise "Project path '#{config.project_path}' does not exist!" unless config.valid_project_path?
      end

      def aggregate_paths
        check_valid_project_path
        aggregate_paths = config.aggregate_paths
        project_path = config.project_path.to_s || Pathname.pwd.to_s
        aggregate_paths = ProjectFinder.new(project_path, config.strict_matching).find_projects if config.recursive

        if aggregate_paths.nil? || aggregate_paths.empty?
          [project_path]
        else
          aggregate_paths
        end
      end

      def save_report(content, file_name)
        dir = File.dirname(file_name)
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)

        File.open(file_name, 'w') do |f|
          f.write(content)
        end
      end

      def report_of(content)
        report = FORMATS[config.format] || FORMATS['text']
        report = MergedReport if report == CsvReport && config.aggregate_paths
        report.of(content, columns: config.columns, project_name: decisions.project_name || config.project_path.basename.to_s, write_headers: config.write_headers)
      end

      def save?
        !!config.save_file
      end
    end
  end
end
