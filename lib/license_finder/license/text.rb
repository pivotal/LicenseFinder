# frozen_string_literal: true

module LicenseFinder
  class License
    module Text
      SPACES = /\s+/.freeze
      QUOTES = /['`"]{1,2}/.freeze
      PLACEHOLDERS = /<[^<>]+>/.freeze
      SPECIAL_SINGLE_QUOTES = /[‘’]/.freeze
      SPECIAL_DOUBLE_QUOTES = /[“”„«»]/.freeze
      ALPHABET_ORDERED_LIST = /\\\([a-z]\\\)\\\s/.freeze
      ALPHABET_ORDERED_LIST_OPTIONAL = '(\([a-z]\)\s)?'
      LIST_BULLETS = /(\d{1,2}\\\.|\\\*|\\\-)\\\s/.freeze
      LIST_BULLETS_OPTIONAL = '(\d{1,2}.|\*|\-)?\s*'
      NEWLINE_CHARACTER = /\n+/.freeze
      QUOTE_COMMENT_CHARACTER = /^\s*\>+/.freeze
      ESCAPED_QUOTES = /\\\"/.freeze

      def self.normalize_punctuation(text)
        text.dup.force_encoding('UTF-8')
            .gsub(SPECIAL_DOUBLE_QUOTES, '"')
            .gsub(SPECIAL_SINGLE_QUOTES, "'")
            .gsub(QUOTE_COMMENT_CHARACTER, '')
            .gsub(SPACES, ' ')
            .gsub(NEWLINE_CHARACTER, ' ')
            .gsub(ESCAPED_QUOTES, '"')
            .gsub(QUOTES, '"')
            .strip
      rescue ArgumentError => _e
        text
      end

      def self.compile_to_regex(text)
        Regexp.new(Regexp.escape(normalize_punctuation(text))
                       .gsub(PLACEHOLDERS, '(.*)')
                       .gsub(',', '(,)?')
                       .gsub('HOLDER', '(HOLDER|OWNER)')
                       .gsub(ALPHABET_ORDERED_LIST, ALPHABET_ORDERED_LIST_OPTIONAL)
                       .gsub(LIST_BULLETS, LIST_BULLETS_OPTIONAL))
      end
    end
  end
end
