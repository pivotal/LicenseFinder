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

        def slug
          demodulized_name.downcase
        end

        def pretty_name
          demodulized_name
        end

        def license_text
          unless defined?(@license_text)
            template = File.join(ROOT_PATH, "data", "licenses", "#{demodulized_name}.txt").to_s

            @license_text = Text.new(File.read(template)).to_s if File.exists?(template)
          end
          @license_text
        end

        def license_regex
          /#{Regexp.escape(license_text).gsub(/<[^<>]+>/, '(.*)')}/ if license_text
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
        !!(text =~ self.class.license_regex if self.class.license_regex)
      end
    end
  end
end

Dir[File.join(File.dirname(__FILE__), 'license', '*.rb')].each do |license|
  require license
end
