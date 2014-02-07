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

    attr_reader :license_url, :alternative_names, :pretty_name, :matching_algorithm, :demodulized_name

    def initialize(settings)
      @demodulized_name   = settings.fetch(:demodulized_name)
      @pretty_name        = settings.fetch(:pretty_name, demodulized_name)
      @alternative_names  = settings.fetch(:alternative_names, [])
      @license_url        = settings.fetch(:license_url)
      @matching_algorithm = settings.fetch(:matching_algorithm) { TemplateMatcher.new(Template.named(demodulized_name)) }
    end

    def matches_name?(name)
      names.map(&:downcase).include? name.to_s.downcase
    end

    def matches_text?(text)
      matching_algorithm.matches_text?(text)
    end

    private

    def names
      ([demodulized_name, pretty_name] + alternative_names).uniq
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

    class RegexpMatcher
      attr_reader :regexp

      def initialize(regexp)
        @regexp = regexp
      end

      def matches_text?(text)
        !!(Text.normalize_punctuation(text) =~ regexp)
      end
    end

    class TextMatcher < RegexpMatcher
      def initialize(text)
        super(Text.compile_to_regex(text))
      end
    end

    class TemplateMatcher < TextMatcher
      def initialize(template)
        super(template.content)
      end
    end

    HeaderMatcher = Struct.new(:base_matcher) do
      def matches_text?(text)
        header = text.split("\n").first || ''
        base_matcher.matches_text?(header)
      end
    end

    class AnyMatcher
      def initialize(*algos)
        @algos = algos
      end

      def matches_text?(text)
        @algos.any? { |a| a.matches_text? text }
      end
    end
  end
end

Pathname.glob(LicenseFinder::ROOT_PATH.join('license_finder', 'license', "*.rb")) do |license|
  require license
end
