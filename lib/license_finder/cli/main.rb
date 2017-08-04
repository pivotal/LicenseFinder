require 'license_finder/report'
require 'license_finder/version'
require 'license_finder/diff'
require 'license_finder/package_delta'
require 'license_finder/license_aggregator'
require 'license_finder/project_finder'

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
      class_option :columns, type: :array, desc: "For text or CSV reports, which columns to print. Pick from: #{CsvReport::AVAILABLE_COLUMNS}", default: %w[name version licenses]
      class_option :save, desc: "Save report to a file. Default: 'license_report.csv' in project root.", lazy_default: "license_report"
      class_option :go_full_version, desc: "Whether dependency version should include full version. Only meaningful if used with a Go project. Defaults to false."
      class_option :gradle_include_groups, desc: "Whether dependency name should include group id. Only meaningful if used with a Java/gradle project. Defaults to false."
      class_option :gradle_command, desc: "Command to use when fetching gradle packages. Only meaningful if used with a Java/gradle project. Defaults to 'gradlew' / 'gradlew.bat' if the wrapper is present, otherwise to 'gradle'."
      class_option :maven_include_groups, desc: "Whether dependency name should include group id. Only meaningful if used with a Java/maven project. Defaults to false."
      class_option :maven_options, desc: "Maven options to append to command. Defaults to empty."
      class_option :python_requirements_path, desc: "Path to python requirements file. Defaults to requirements.txt."
      class_option :rebar_command, desc: "Command to use when fetching rebar packages. Only meaningful if used with a Erlang/rebar project. Defaults to 'rebar'."
      class_option :rebar_deps_dir, desc: "Path to rebar dependencies directory. Only meaningful if used with a Erlang/rebar project. Defaults to 'deps'."
      class_option :subprojects, type: :array, desc: "Generate a single report for multiple sub-projects. Ex: --subprojects='path/to/project1', 'path/to/project2'"
      class_option :recursive, desc: "Recursively runs License Finder on all sub-projects."

      method_option :quiet, type: :boolean, desc: "silences progress report"
      method_option :debug, type: :boolean, desc: "emit detailed info about what LicenseFinder is doing"
      desc "action_items", "List unapproved dependencies (the default action for `license_finder`)"

      def action_items
        any_packages = license_finder.any_packages?
        unapproved = license_finder.unapproved
        blacklisted = license_finder.blacklisted

        # Ensure to start output on a new line even with dot progress indicators.
        say "\n"

        unless any_packages
          say "No dependencies recognized!", :red
          exit 0
        end

        if unapproved.empty?
          say "All dependencies are approved for use", :green
        else
          unless blacklisted.empty?
            say "Blacklisted dependencies:", :red
            say report_of(blacklisted)
          end

          other_unapproved = unapproved - blacklisted
          unless other_unapproved.empty?
            say "Dependencies that need approval:", :yellow
            say report_of(other_unapproved)
          end

          exit 1
        end
      end

      default_task :action_items

      desc "report", "Print a report of the project's dependencies to stdout"

      def report
        logger_config[:quiet] = true

        subproject_paths = options[:subprojects] if subprojects?
        subproject_paths = ProjectFinder.new(license_finder.config.project_path).find_projects if recursive?

        if subproject_paths && !subproject_paths.empty?
          finder = LicenseAggregator.new(license_finder_config, subproject_paths)
          report = MergedReport.new(finder.dependencies, options)
        else
          report = report_of(license_finder.acknowledged)
        end
        save? ? save_report(report, options[:save]) : say(report)
      end

      desc "version", "Print the version of LicenseFinder"

      def version
        puts LicenseFinder::VERSION
      end

      desc "diff OLDFILE NEWFILE", "Command to view the differences between two generated reports (csv)."

      def diff(file1, file2)
        f1 = IO.read(file1)
        f2 = IO.read(file2)
        report = DiffReport.new(Diff.compare(f1, f2))
        save? ? save_report(report, options[:save]) : say(report)
      end

      subcommand "dependencies", Dependencies, "Add or remove dependencies that your package managers are not aware of"
      subcommand "licenses", Licenses, "Set a dependency's licenses, if the licenses found by license_finder are missing or wrong"
      subcommand "approvals", Approvals, "Manually approve dependencies, even if their licenses are not whitelisted"
      subcommand "ignored_groups", IgnoredGroups, "Exclude test and development dependencies from action items and reports"
      subcommand "ignored_dependencies", IgnoredDependencies, "Exclude individual dependencies from action items and reports"
      subcommand "whitelist", Whitelist, "Automatically approve any dependency that has a whitelisted license"
      subcommand "blacklist", Blacklist, "Forbid approval of any dependency whose licenses are all blacklisted"
      subcommand "project_name", ProjectName, "Set the project name, for display in reports"

      private

      def save_report(content, file_name)
        File.open(file_name, 'w') do |f|
          f.write(content)
        end
      end

      def report_of(content)
        report = FORMATS[options[:format]]
        report.of(content, columns: options[:columns], project_name: license_finder.project_name)
      end

      def save?
        !!options[:save]
      end

      def recursive?
        !!options[:recursive]
      end

      def subprojects?
        !!options[:subprojects]
      end
    end
  end
end
