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
  end
end
