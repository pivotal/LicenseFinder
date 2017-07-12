require 'spdx-licenses'

require "license_finder/license/text"
require "license_finder/license/template"

require "license_finder/license/matcher"
require "license_finder/license/header_matcher"
require "license_finder/license/any_matcher"
require "license_finder/license/none_matcher"

require "license_finder/license/definitions"

module LicenseFinder
  class License
    class << self
      def all
        @all ||= Definitions.all
      end

      def find_by_name(name)
        name ||= "unknown"
        all.detect { |l| l.matches_name? name } || Definitions.build_unrecognized(name)
      end

      def find_by_text(text)
        all.detect { |l| l.matches_text? text }
      end

      def find_by_spdx(spdx_string)
        all.detect { |l| l.spdx == spdx_string && l.valid_spdx?(l.spdx) }
      end
    end

    def initialize(settings)
      @short_name  = settings.fetch(:short_name)
      @pretty_name = settings.fetch(:pretty_name, short_name)
      @other_names = settings.fetch(:other_names, [])
      @url         = settings.fetch(:url)
      @spdx        = settings.fetch(:spdx, [])
      @matcher     = settings.fetch(:matcher) { Matcher.from_template(Template.named(short_name)) }
    end

    attr_reader :url, :spdx

    def name
      pretty_name
    end

    def matches_name?(name)
      names.map(&:downcase).include? name.to_s.downcase
    end

    def matches_text?(text)
      matcher.matches_text?(text)
    end

    def valid_spdx?(text)
      SpdxLicenses.lookup(text)
    end

    def eql?(other)
      name == other.name
    end

    def hash
      name.hash
    end

    private

    attr_reader :short_name, :pretty_name, :other_names
    attr_reader :matcher

    def names
      ([short_name, pretty_name] + other_names).uniq
    end
  end
end
