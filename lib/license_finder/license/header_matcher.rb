# frozen_string_literal: true

module LicenseFinder
  class License
    HeaderMatcher = Struct.new(:base_matcher, :first_n_lines) do
      def matches_text?(text)
        n = if first_n_lines.nil?
              1
            else
              first_n_lines
            end
        header = text.lines.first(n).join || ''
        base_matcher.matches_text?(header)
      end
    end
  end
end
