module LicenseFinder
  class License
    class << self
      def all
        @all ||= Definitions.build_all(LicenseFinder.config.whitelist)
      end

      def find_by_name(name)
        all.detect { |l| l.matches_name? name } || Definitions.build_unrecognized(name, LicenseFinder.config.whitelist)
      end

      def find_by_text(text)
        all.detect { |l| l.matches_text? text }
      end
    end

    autoload :Definitions,   "license_finder/license/definitions"
    autoload :Names,         "license_finder/license/names"
    autoload :Text,          "license_finder/license/text"
    autoload :Template,      "license_finder/license/template"
    autoload :Matcher,       "license_finder/license/matcher"
    autoload :HeaderMatcher, "license_finder/license/header_matcher"
    autoload :AnyMatcher,    "license_finder/license/any_matcher"
    autoload :NoneMatcher,   "license_finder/license/none_matcher"

    attr_reader :url

    def initialize(settings)
      @names       = settings.fetch(:names)
      @url         = settings.fetch(:url)
      @whitelisted = settings.fetch(:whitelisted)
      @matcher     = settings.fetch(:matcher)
    end

    def whitelisted?
      @whitelisted
    end

    def name
      @names.pretty_name
    end

    def matches_name?(name)
      @names.matches_name?(name)
    end

    def matches_text?(text)
      @matcher.matches_text?(text)
    end
  end
end
