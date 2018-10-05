# frozen_string_literal: true

module LicenseFinder
  class DecisionsFactory
    @decisions = {}
    class << self
      def decisions(decisions_file_path)
        @decisions[decisions_file_path] = Decisions.fetch_saved(decisions_file_path) if @decisions[decisions_file_path].nil?
        @decisions[decisions_file_path]
      end
    end
  end
end
