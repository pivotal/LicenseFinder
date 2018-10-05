# frozen_string_literal: true

module LicenseFinder
  class License
    class AnyMatcher
      def initialize(*matchers)
        @matchers = matchers
      end

      def matches_text?(text)
        @matchers.any? { |m| m.matches_text? text }
      end
    end
  end
end
