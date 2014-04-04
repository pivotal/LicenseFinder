module LicenseFinder
  class License
    class << self
      def all
        @all ||= []
      end

      def find_by_name(name)
        all.detect { |l| l.matches_name? name } || UnknownLicense.new(name)
      end

      def find_by_text(text)
        all.detect { |l| l.matches_text? text } || UnknownLicense.new
      end
    end

    autoload :Text,          "license_finder/license/text"
    autoload :Template,      "license_finder/license/template"
    autoload :Matcher,       "license_finder/license/matcher"
    autoload :HeaderMatcher, "license_finder/license/header_matcher"
    autoload :AnyMatcher,    "license_finder/license/any_matcher"

    attr_reader :url, :pretty_name

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

    attr_reader :short_name, :other_names, :matcher

    def names
      ([short_name, pretty_name] + other_names).uniq
    end
  end

  class UnknownLicense
    attr_reader :pretty_name

    def initialize(name = nil)
      @pretty_name = name
    end
    def url; end

    def ==(other)
      pretty_name.eql?(other.pretty_name)
    end
  end
end

require LicenseFinder::ROOT_PATH.join("license_finder", "license", "definitions.rb")
