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
      if options.has_key?(:approve)
        dependency = Dependency.find_by_name(options[:approve])
        dependency.approve!
        puts "The #{dependency.name} has been approved!\n\n"
        check_for_action_items
      else
        check_for_action_items
      end
    end
  end
end
