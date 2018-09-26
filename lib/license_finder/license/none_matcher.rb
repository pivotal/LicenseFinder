# frozen_string_literal: true

module LicenseFinder
  class License
    class NoneMatcher
      def matches_text?(_text)
        false
      end
    end
  end
end
