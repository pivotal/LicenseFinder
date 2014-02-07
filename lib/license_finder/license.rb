module LicenseFinder
  module License
    class << self
      def all
        @all ||= []
      end

      def find_by_name(license_name)
        all.detect { |l| l.names.map(&:downcase).include? license_name.to_s.downcase }
      end

      def find_by_text(text)
        all.detect { |klass| klass.new(text).matches? }
      end
    end

    module Text
      SPACES = /\s+/
      QUOTES = /['`"]{1,2}/
      PLACEHOLDERS = /<[^<>]+>/

      def self.normalize_punctuation(text)
        text.gsub(SPACES, ' ')
            .gsub(QUOTES, '"')
      end

      def self.compile_to_regex(text)
        Regexp.new(Regexp.escape(text).gsub(PLACEHOLDERS, '(.*)'))
      end
    end

    class Base
      class << self
        attr_accessor :license_url
        attr_writer :alternative_names, :pretty_name

        def inherited(descendant)
          License.all << descendant
        end

        def names
          ([demodulized_name, pretty_name] + self.alternative_names).uniq
        end

        def alternative_names
          @alternative_names ||= []
        end

        def pretty_name
          @pretty_name ||= demodulized_name
        end

        def demodulized_name
          name.gsub(/^.*::/, '')
        end

        def license_text
          @license_text ||= Text.normalize_punctuation(template.read)
        end

        def license_regex
          Text.compile_to_regex(license_text)
        end

        def template
          ROOT_PATH.join("data", "licenses", "#{demodulized_name}.txt")
        end
      end

      def initialize(text)
        self.text = text
      end

      attr_reader :text, :raw_text

      def text=(text)
        @raw_text = text
        @text = Text.normalize_punctuation(text)
      end

      def matches?
        text_matches? self.class.license_regex
      end

      private

      def text_matches?(regex)
        !!(text =~ regex)
      end
    end
  end
end

Pathname.glob(LicenseFinder::ROOT_PATH.join('license_finder', 'license', "*.rb")) do |license|
  require license
end
