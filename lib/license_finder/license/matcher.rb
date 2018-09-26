# frozen_string_literal: true

module LicenseFinder
  class License
    Matcher = Struct.new(:regexp) do
      def self.from_template(template)
        from_text(template.content)
      end

      def self.from_text(text)
        from_regex(Text.compile_to_regex(text))
      end

      # an alias for Matcher.new, for uniformity of constructors
      def self.from_regex(regexp)
        new(regexp)
      end

      def matches_text?(text)
        !!(Text.normalize_punctuation(text) =~ regexp)
      end
    end
  end
end
