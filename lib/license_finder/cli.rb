module LicenseFinder
  module CLI
    extend self

    def check_for_action_items
      found = LicenseFinder::Reporter.new.action_items

      if found.size == 0
        puts "All gems are approved for use"
      else
        puts "Dependencies that need approval:"
        puts found
        exit 1
      end
    end

    def execute! options={}
      unless options.empty?
        dependency = Dependency.find_by_name(options[:dependency])

        if options[:approve]
          dependency.approve!
          puts "The #{dependency.name} has been approved!\n\n"
        elsif options[:license]
          dependency.update_attributes :license => options[:license]
          puts "The #{dependency.name} has been marked as using #{options[:license]} license!\n\n"
        end
      end


      check_for_action_items
    end
  end
end
