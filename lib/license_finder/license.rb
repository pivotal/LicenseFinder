module LicenseFinder
  class License
    class << self
      def all
        @all ||= []
      end

      def find_by_name(name)
        all.detect { |l| l.matches_name? name }
      end

      def find_by_text(text)
        all.detect { |l| l.matches_text? text }
      end
    end

    attr_reader :url, :other_names, :pretty_name, :matcher, :short_name

    def initialize(settings)
      @short_name  = settings.fetch(:short_name)
      @pretty_name = settings.fetch(:pretty_name, short_name)
      @other_names = settings.fetch(:other_names, [])
      @url         = settings.fetch(:url)
      @matcher     = settings.fetch(:matcher) { Matcher.from_template(Template.named(short_name)) }
    end

    def matches_name?(name)
      names.map(&:downcase).include? name.to_s.downcase
    end

    def matches_text?(text)
      matcher.matches_text?(text)
    end

    private

    def names
      ([short_name, pretty_name] + other_names).uniq
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

    class Template
      def self.named(name)
        path = ROOT_PATH.join("data", "licenses", "#{name}.txt")
        new(path.read)
      end

      attr_reader :content

      def initialize(raw_content)
        @content = Text.normalize_punctuation(raw_content)
      end
    end

    class Matcher
      attr_reader :regexp

      def self.from_template(template)
        from_text(template.content)
      end

      def self.from_text(text)
        new(Text.compile_to_regex(text))
      end

      def initialize(regexp)
        @regexp = regexp
      end

      def matches_text?(text)
        !!(Text.normalize_punctuation(text) =~ regexp)
      end
    end

    HeaderMatcher = Struct.new(:base_matcher) do
      def matches_text?(text)
        header = text.split("\n").first || ''
        base_matcher.matches_text?(header)
      end
    end

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

Pathname.glob(LicenseFinder::ROOT_PATH.join('license_finder', 'license', "*.rb")) do |license|
  require license
end
