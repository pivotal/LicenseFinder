require 'license_finder/report'
require 'license_finder/version'

module LicenseFinder
  module CLI
    class Main < Base
      extend Rootcommand

      FORMATS = {
        'text' => TextReport,
        'html' => HtmlReport,
        'markdown' => MarkdownReport,
        'csv' => CsvReport
      }

      class_option :format, desc: "The desired output format.", default: 'text', enum: FORMATS.keys
      class_option :columns, type: :array, desc: "For CSV reports, which columns to print. Pick from: #{CsvReport::AVAILABLE_COLUMNS}", default: %w[name version licenses]
      class_option :gradle_command, desc: "Command to use when fetching gradle packages. Only meaningful if used with a Java/gradle project. Defaults to 'gradle'."
      class_option :rebar_command, desc: "Command to use when fetching rebar packages. Only meaningful if used with a Erlang/rebar project. Defaults to 'rebar'."
      class_option :rebar_deps_dir, desc: "Path to rebar dependencies directory. Only meaningful if used with a Erlang/rebar project. Defaults to 'deps'."

      method_option :quiet, type: :boolean, desc: "silences progress report"
      method_option :debug, type: :boolean, desc: "emit detailed info about what LicenseFinder is doing"
      desc "action_items", "List unapproved dependencies (the default action for `license_finder`)"
      def action_items
        unapproved = license_finder.unapproved

        if unapproved.empty?
          say "All dependencies are approved for use", :green
        else
          say "Dependencies that need approval:", :red
          say report_of(unapproved)
          exit 1
        end
      end

      default_task :action_items

      desc "report", "Print a report of the project's dependencies to stdout"
      def report
        logger_config[:quiet] = true
        say report_of(license_finder.acknowledged)
      end

      desc "version", "Print the version of LicenseFinder"
      def version
        puts LicenseFinder::VERSION
      end

      subcommand "dependencies", Dependencies, "Add or remove dependencies that your package managers are not aware of"
      subcommand "licenses", Licenses, "Set a dependency's licenses, if the licenses found by license_finder are missing or wrong"
      subcommand "approvals", Approvals, "Manually approve dependencies, even if their licenses are not whitelisted"
      subcommand "ignored_groups", IgnoredGroups, "Exclude test and development dependencies from action items and reports"
      subcommand "ignored_dependencies", IgnoredDependencies, "Exclude individual dependencies from action items and reports"
      subcommand "whitelist", Whitelist, "Automatically approve any dependency that has a whitelisted license"
      subcommand "project_name", ProjectName, "Set the project name, for display in reports"

      private

      def report_of(content)
        report = FORMATS[options[:format]]
        report.of(content, columns: options[:columns], project_name: license_finder.project_name)
      end
    end
  end
end
