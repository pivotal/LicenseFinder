module LicenseFinder
  module CLI
    extend self

    @@run_complete = false

    def check_for_action_items
      BundleSyncer.sync!
      @@run_complete = true
      generate_reports

      unapproved = Dependency.unapproved

      puts "\r" + " "*24
      if unapproved.count == 0
        puts "All gems are approved for use"
      else
        puts "Dependencies that need approval:"
        puts TextReport.new(unapproved)
        exit 1
      end
    end

    def execute!(options={})
      if options.empty?
        check_for_action_items
      else
        dependency = Dependency.find_by_name(options[:dependency])

        @@run_complete = true
        puts "\r" + " "*24
        if options[:approve]
          dependency.approve!
          puts "The #{dependency.name} has been approved!\n\n"
        elsif options[:license]
          dependency.set_license_manually options[:license]
          puts "The #{dependency.name} has been marked as using #{options[:license]} license!\n\n"
        end

        generate_reports
      end
    end

    private
    def generate_reports
      LicenseFinder::Reporter.write_reports
    end
  end
end
