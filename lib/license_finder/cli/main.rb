module LicenseFinder
  module CLI
    class Main < Base
      FORMATS = {
        'text' => TextReport,
        'detailed_text' => DetailedTextReport,
        'html' => HtmlReport,
        'markdown' => MarkdownReport
      }

      method_option :quiet, type: :boolean, desc: "silences progress report"
      method_option :debug, type: :boolean, desc: "emit detailed info about what LicenseFinder is doing"
      method_option :format, desc: "The desired output format. Pick from: #{FORMATS.keys.inspect}", default: 'text'
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

      desc "approve DEPENDENCY_NAME...", "Approve one or more dependencies by name"
      def approve(name, *other_names)
        names = other_names.unshift name
        modifying { names.each { |name| decisions.approve(name, txn) } }

        say "The #{names.join(", ")} dependency has been approved!", :green
      end

      desc "license LICENSE DEPENDENCY_NAME", "Update a dependency's license"
      def license(license, name)
        modifying { decisions.license(name, license, txn) }

        say "The #{name} dependency has been marked as using #{license} license!", :green
      end

      method_option :format, desc: "The desired output format. Pick from: #{FORMATS.keys.inspect}", default: 'text'
      desc "report", "Print a report of the project's dependencies to stdout"
      def report
        dependencies = decision_applier(Logger.new(quiet: true))
        say report_of(dependencies.acknowledged)
      end

      subcommand "dependencies", Dependencies, "Manually manage dependencies that your package managers are not aware of"
      subcommand "ignored_groups", IgnoredGroups, "Manage ignored groups"
      subcommand "ignored_dependencies", IgnoredDependencies, "Manage ignored dependencies"
      subcommand "whitelist", Whitelist, "Manage whitelisted licenses"
      subcommand "project_name", ProjectName, "Manage the project name, for display in reports"

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
        report.of(content, decisions.project_name)
      end
    end
  end
end
