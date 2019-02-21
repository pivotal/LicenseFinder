# frozen_string_literal: true

module LicenseFinder
  class License
    module Text
      SPACES = /\s+/.freeze
      QUOTES = /['`"]{1,2}/.freeze
      PLACEHOLDERS = /<[^<>]+>/.freeze

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
