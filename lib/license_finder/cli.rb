require 'thor'

module LicenseFinder
  class CLI < Thor
    no_commands do
      def spinner
        if options[:quiet]
          yield
        else
          thread = Thread.new() {
            wheel = '\|/-'
            i = 0
            while true do
              print "\r ---------- #{wheel[i]} ----------"
              i = (i + 1) % 4
            end
          }
          yield
          thread.kill
          puts "\r" + " "*24
        end
      end
    end


    option :quiet, type: :boolean, aliases: :q
    desc "rescan", "Find new dependencies."
    def rescan
      spinner {
        BundleSyncer.sync!
        generate_reports
      }

      unapproved = Dependency.unapproved

      if unapproved.count == 0
        say "All gems are approved for use", :green
      else
        say "Dependencies that need approval:", :red
        say TextReport.new(unapproved)
        exit 1
      end
    end
    default_task :rescan

    desc "approve DEPENDENCY_NAME", "Approve a dependency by name."
    def approve(name)
      dependency = Dependency.first(name: name)
      dependency.approve!

      say "The #{dependency.name} has been approved!\n\n", :green

      generate_reports
    end

    desc "license LICENSE DEPENDENCY_NAME", "Update a dependency's license."
    def license(license, name)
      dependency = Dependency.first(name: name)
      dependency.set_license_manually license

      say "The #{name} has been marked as using #{license} license!\n\n", :green

      generate_reports
    end

    desc "move", "Move dependency.* files from root directory to doc/."
    def move
      `sed '$d' < config/license_finder.yml > tmp34567.txt`
      `mv tmp34567.txt config/license_finder.yml`
      `echo "dependencies_file_dir: './doc/'" >> config/license_finder.yml`
      `mkdir -p doc`
      `mv dependencies.* doc/`
      say "Congratulations, you have cleaned up your root directory!'", :green
    end

    private

    def generate_reports
      Reporter.write_reports
    end
  end
end
