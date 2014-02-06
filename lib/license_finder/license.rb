module LicenseFinder
  module License
    class << self
      def all
        @all ||= []
      end

      def find_by_name(license_name)
        all.detect { |l| l.names.map(&:downcase).include? license_name.to_s.downcase }
      end
    end

    class Text
      def initialize(text)
        @text = normalized(text)
      end

      def to_s
        @text
      end

      private

      def normalized(text)
        text.gsub(/\s+/, ' ').gsub(/['`"]{1,2}/, "\"")
      end
    end

    class Base
      class << self
        attr_accessor :license_url, :alternative_names

        def inherited(descendant)
          License.all << descendant
        end

        def names
          ([demodulized_name, pretty_name] + self.alternative_names).uniq
        end

        def alternative_names
          @alternative_names ||= []
        end

        def demodulized_name
          name.gsub(/^.*::/, '')
        end

        def pretty_name
          demodulized_name
        end

        def compile_text_to_regex(text)
          Regexp.new(Regexp.escape(text).gsub(/<[^<>]+>/, '(.*)'))
        end

        def license_text
          unless defined?(@license_text)
            @license_text = Text.new(template.read).to_s if template.exist?
          end
          @license_text
        end

        def license_regex
          compile_text_to_regex(license_text) if license_text
        end

        def template
          ROOT_PATH.join("data", "licenses", "#{demodulized_name}.txt")
        end
      end

      def initialize(text)
        self.text = text
      end

      attr_reader :text

      def text=(text)
        @text = Text.new(text).to_s
      end

      def matches?
        text_matches? self.class.license_regex
      end

      private

      def text_matches?(regex)
        !!(text =~ regex if regex)
      end
    end
  end
end

Pathname.glob(LicenseFinder::ROOT_PATH.join('license_finder', 'license', "*.rb")) do |license|
  require license
end
