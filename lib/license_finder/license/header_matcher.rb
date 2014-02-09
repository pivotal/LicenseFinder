module LicenseFinder
  class License
    HeaderMatcher = Struct.new(:base_matcher) do
      def matches_text?(text)
        header = text.split("\n").first || ''
        base_matcher.matches_text?(header)
      end
    end
  end
end
