module LicenseFinder
  class License
    module Text
      SPACES = /\s+/
      QUOTES = /['`"]{1,2}/
      PLACEHOLDERS = /<[^<>]+>/

      def self.normalize_punctuation(text)
        text.gsub(SPACES, ' ')
            .gsub(QUOTES, '"')
            .strip
      end

      def self.compile_to_regex(text)
        Regexp.new(Regexp.escape(text).gsub(PLACEHOLDERS, '(.*)'))
      end
    end
  end
end
