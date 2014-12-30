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

      method_option :quiet, type: :boolean, desc: "silences progress report"
      method_option :debug, type: :boolean, desc: "emit detailed info about what LicenseFinder is doing"
      method_option :format, desc: "The desired output format. Pick from: #{FORMATS.keys.inspect}", default: 'text'
      method_option :columns, type: :array, desc: "For CSV reports, which columns to print. Pick from: #{CsvReport::AVAILABLE_COLUMNS}", default: %w[name version licenses]
      desc "action_items", "List unapproved dependencies (the default action for `license_finder`)"
      def action_items
        unapproved = decision_applier.unapproved

        if unapproved.empty?
          say "All dependencies are approved for use", :green
        else
          say "Dependencies that need approval:", :red
          say report_of(unapproved)
          exit 1
        end
      end

      default_task :action_items

      method_option :format, desc: "The desired output format. Pick from: #{FORMATS.keys.inspect}", default: 'text'
      method_option :columns, type: :array, desc: "For CSV reports, which columns to print. Pick from: #{CsvReport::AVAILABLE_COLUMNS}", default: %w[name version licenses]
      desc "report", "Print a report of the project's dependencies to stdout"
      def report
        dependencies = decision_applier(Logger.new(quiet: true))
        say report_of(dependencies.acknowledged)
      end

      subcommand "dependencies", Dependencies, "Add or remove dependencies that your package managers are not aware of"
      subcommand "licenses", Licenses, "Set a dependency's licenses, if the licenses found by license_finder are missing or wrong"
      subcommand "approvals", Approvals, "Manually approve dependencies, even if their licenses are not whitelisted"
      subcommand "ignored_groups", IgnoredGroups, "Exclude test and development dependencies from action items and reports"
      subcommand "ignored_dependencies", IgnoredDependencies, "Exclude individual dependencies from action items and reports"
      subcommand "whitelist", Whitelist, "Automatically approve any dependency that has a whitelisted license"
      subcommand "project_name", ProjectName, "Set the project name, for display in reports"

      private

      # The core of the system. The saved decisions are applied to the current
      # packages.
      def decision_applier(logger = Logger.new(options))
        @decision_applier ||= DecisionApplier.new(
          decisions: decisions,
          packages: PackageManager.current_packages(logger)
        )
      end

      def report_of(content)
        report = FORMATS[options[:format]]
        if !report
          say "Format #{options[:format]} not recognized. Valid formats #{FORMATS.keys.inspect}", :red
          exit 1
        end
        report.of(content, columns: options[:columns], project_name: decisions.project_name)
      end
    end
  end
end
