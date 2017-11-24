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
        'csv' => CsvReport
      }.freeze

      class_option :format, desc: 'The desired output format.', default: 'text', enum: FORMATS.keys
      class_option :columns, type: :array, desc: "For text or CSV reports, which columns to print. Pick from: #{CsvReport::AVAILABLE_COLUMNS}"
      class_option :go_full_version, desc: 'Whether dependency version should include full version. Only meaningful if used with a Go project. Defaults to false.'
      class_option :gradle_include_groups, desc: 'Whether dependency name should include group id. Only meaningful if used with a Java/gradle project. Defaults to false.'
      class_option :gradle_command,
                   desc: "Command to use when fetching gradle packages. Only meaningful if used with a Java/gradle project.
                          Defaults to 'gradlew' / 'gradlew.bat' if the wrapper is present, otherwise to 'gradle'."
      class_option :maven_include_groups, desc: 'Whether dependency name should include group id. Only meaningful if used with a Java/maven project. Defaults to false.'
      class_option :maven_options, desc: 'Maven options to append to command. Defaults to empty.'
      class_option :pip_requirements_path, desc: 'Path to python requirements file. Defaults to requirements.txt.'
      class_option :rebar_command, desc: "Command to use when fetching rebar packages. Only meaningful if used with a Erlang/rebar project. Defaults to 'rebar'."
      class_option :rebar_deps_dir, desc: "Path to rebar dependencies directory. Only meaningful if used with a Erlang/rebar project. Defaults to 'deps'."
      class_option :mix_command, desc: "Command to use when fetching packages through Mix. Only meaningful if used with a Mix project (i.e., Elixir or Erlang). Defaults to 'mix'."
      class_option :mix_deps_dir, desc: "Path to Mix dependencies directory. Only meaningful if used with a Mix project (i.e., Elixir or Erlang). Defaults to 'deps'."

      # Method options which are shared between report and action_item
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
      end

      desc 'action_items', 'List unapproved dependencies (the default action for `license_finder`)'
      shared_options
      def action_items
        finder = LicenseAggregator.new(license_finder_config, aggregate_paths)
        any_packages = finder.any_packages?
        unapproved = finder.unapproved
        blacklisted = finder.blacklisted

        # Ensure to start output on a new line even with dot progress indicators.
        say "\n"

        unless any_packages
          say 'No dependencies recognized!', :red
          exit 0
        end

        if unapproved.empty?
          say 'All dependencies are approved for use', :green
        else
          unless blacklisted.empty?
            say 'Blacklisted dependencies:', :red
            say report_of(blacklisted)
          end

          other_unapproved = unapproved - blacklisted
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
      method_option :save, desc: "Save report to a file. Default: 'license_report.csv' in project root.", lazy_default: 'license_report'

      def report
        logger_config[:mode] = Logger::MODE_QUIET

        finder = LicenseAggregator.new(license_finder_config, aggregate_paths)
        report = report_of(finder.dependencies)
        save? ? save_report(report, options[:save]) : say(report)
      end

      desc 'version', 'Print the version of LicenseFinder'
      def version
        puts LicenseFinder::VERSION
      end

      desc 'diff OLDFILE NEWFILE', 'Command to view the differences between two generated reports (csv).'
      method_option :save, desc: "Save report to a file. Default: 'license_report.csv' in project root.", lazy_default: 'license_report'
      def diff(file1, file2)
        f1 = IO.read(file1)
        f2 = IO.read(file2)
        report = DiffReport.new(Diff.compare(f1, f2))
        save? ? save_report(report, options[:save]) : say(report)
      end

      subcommand 'dependencies', Dependencies, 'Add or remove dependencies that your package managers are not aware of'
      subcommand 'licenses', Licenses, "Set a dependency's licenses, if the licenses found by license_finder are missing or wrong"
      subcommand 'approvals', Approvals, 'Manually approve dependencies, even if their licenses are not whitelisted'
      subcommand 'ignored_groups', IgnoredGroups, 'Exclude test and development dependencies from action items and reports'
      subcommand 'ignored_dependencies', IgnoredDependencies, 'Exclude individual dependencies from action items and reports'
      subcommand 'whitelist', Whitelist, 'Automatically approve any dependency that has a whitelisted license'
      subcommand 'blacklist', Blacklist, 'Forbid approval of any dependency whose licenses are all blacklisted'
      subcommand 'project_name', ProjectName, 'Set the project name, for display in reports'

      private

      def aggregate_paths
        aggregate_paths = options[:aggregate_paths]
        aggregate_paths = ProjectFinder.new(license_finder.config.project_path).find_projects if options[:recursive]
        return aggregate_paths unless aggregate_paths.nil? || aggregate_paths.empty?
        [license_finder_config[:project_path]] unless license_finder_config[:project_path].nil?
      end

      def save_report(content, file_name)
        File.open(file_name, 'w') do |f|
          f.write(content)
        end
      end

      def report_of(content)
        report = FORMATS[options[:format]]
        if report == CsvReport && options[:aggregate_paths] then report = MergedReport end
        report.of(content, columns: options[:columns], project_name: license_finder.project_name)
      end

      def save?
        !!options[:save]
      end

      def prepare?
        options[:prepare]
      end

      def run_prepare_phase
        license_finder.prepare_projects
      end
    end
  end
end
