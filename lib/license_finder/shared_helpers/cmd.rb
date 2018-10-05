# frozen_string_literal: true

require 'open3'

module LicenseFinder
  module SharedHelpers
    class Cmd
      def self.run(command)
        Open3.capture3(command)
      end
    end
  end
end
