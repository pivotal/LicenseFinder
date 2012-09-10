
module LicenseFinder
  class CLI
    def check_for_action_items
      found = LicenseFinder::Finder.new.action_items

      if found.size == 0
        puts "All gems are approved for use"
        exit 0
      else
        puts "Dependencies that need approval:"
        puts found
        exit 1
      end
    end
  end
end
