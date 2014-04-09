module LicenseFinder
  class License
    class << self
      def all
        @all ||= Definitions.all(LicenseFinder.config.whitelist)
      end

      def find_by_name(name)
        name ||= "other"
        all.detect { |l| l.matches_name? name } || Definitions.build_unrecognized(name, LicenseFinder.config.whitelist)
      end

      def find_by_text(text)
        all.detect { |l| l.matches_text? text }
      end
    end

    autoload :Definitions,   "license_finder/license/definitions"
    autoload :Text,          "license_finder/license/text"
    autoload :Template,      "license_finder/license/template"
    autoload :Matcher,       "license_finder/license/matcher"
    autoload :HeaderMatcher, "license_finder/license/header_matcher"
    autoload :AnyMatcher,    "license_finder/license/any_matcher"
    autoload :NoneMatcher,   "license_finder/license/none_matcher"

    def initialize(settings)
      @short_name  = settings.fetch(:short_name)
      @pretty_name = settings.fetch(:pretty_name, short_name)
      @other_names = settings.fetch(:other_names, [])
      @url         = settings.fetch(:url)
      @whitelisted = settings.fetch(:whitelisted, false)
      @matcher     = settings.fetch(:matcher) { Matcher.from_template(Template.named(short_name)) }
    end

    attr_reader :url

    def name
      pretty_name
    end

    def matches_name?(name)
      names.map(&:downcase).include? name.to_s.downcase
    end

    def matches_text?(text)
      matcher.matches_text?(text)
    end

    def whitelisted?
      @whitelisted
    end

    def whitelist
      copy(whitelisted: true)
    end

    private

    attr_reader :short_name, :pretty_name, :other_names
    attr_reader :matcher

    def names
      ([short_name, pretty_name] + other_names).uniq
    end

    def copy(overrides)
      settings = {
        short_name:  short_name,
        pretty_name: pretty_name,
        other_names: other_names,
        url:         url,
        whitelisted: whitelisted?,
        matcher:     matcher
      }
      self.class.new(settings.merge(overrides))
    end
  end
end
