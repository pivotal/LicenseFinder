module LicenseFinder
  class License
    class NoneMatcher
      def matches_text?(text)
        false
      end
    end
  end
end
