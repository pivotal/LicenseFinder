require 'thor'

module LicenseFinder
  class CLI < Thor
    option :quiet, type: :boolean, aliases: :q
    desc "rescan", "Find new dependencies."
    def rescan
      spinner {
        BundleSyncer.sync!
        Reporter.write_reports
      }

      action_items
    end
    default_task :rescan

    desc "approve DEPENDENCY_NAME", "Approve a dependency by name."
    def approve(name)
      dependency = Dependency.first(name: name)
      dependency.approve!

      say "The #{dependency.name} dependency has been approved!", :green

      Reporter.write_reports
    end

    desc "license LICENSE DEPENDENCY_NAME", "Update a dependency's license."
    def license(license, name)
      dependency = Dependency.first(name: name)
      dependency.set_license_manually license

      say "The #{name} dependency has been marked as using #{license} license!", :green

      Reporter.write_reports
    end

    desc "move", "Move dependency.* files from root directory to doc/."
    def move
      config = Configuration.config_hash('dependencies_file_dir' => './doc/')
      File.open(Configuration.config_file_path, 'w') do |f|
        f.write YAML.dump(config)
      end

      FileUtils.mkdir_p("doc")
      FileUtils.mv(Dir["dependencies.*"], "doc")
      say "Congratulations, you have cleaned up your root directory!'", :green
    end

    desc "action_items", "List unapproved dependencies"
    def action_items
      unapproved = Dependency.unapproved

      if unapproved.count == 0
        say "All gems are approved for use", :green
      else
        say "Dependencies that need approval:", :red
        say TextReport.new(unapproved)
        exit 1
      end
    end

    class Dependencies < Thor
      desc "add LICENSE DEPENDENCY_NAME [VERSION]", "Add a dependency that is not managed by Bundler"
      def add(license, name, version = nil)
        Dependency.create_non_bundler(license, name, version)
        say "The #{name} dependency has been added!", :green

        Reporter.write_reports
      rescue LicenseFinder::Error => e
        say e.message, :red
      end

      desc "remove DEPENDENCY_NAME", "Remove a dependency that is not managed by Bundler"
      def remove(name)
        Dependency.destroy_non_bundler(name)
        say "The #{name} dependency has been removed.", :green

        Reporter.write_reports
      rescue LicenseFinder::Error => e
        say e.message, :red
      end
    end

    desc "dependencies SUBCOMMAND ...ARGS", "manual add and manage non bundler dependencies"
    subcommand "dependencies", Dependencies

    private

    def spinner
      if options[:quiet]
        yield
      else
        begin
          thread = Thread.new {
            wheel = '\|/-'
            i = 0
            while true do
              print "\r ---------- #{wheel[i]} ----------"
              i = (i + 1) % 4
            end
          }
          yield
        ensure
          if thread
            thread.kill
            puts "\r" + " "*24
          end
        end
      end
    end
  end
end
