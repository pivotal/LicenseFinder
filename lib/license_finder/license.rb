module LicenseFinder::License
  class << self
    def all
      @all ||= []
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
      text.gsub(/\s+/, ' ').gsub("'", "\"")
    end
  end

  class Base
    class << self
      def inherited(descendant)
        LicenseFinder::License.all << descendant
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
          template = File.join(LicenseFinder::ROOT_PATH, "templates", "#{demodulized_name}.txt").to_s

          @license_text = Text.new(File.read(template)).to_s if File.exists?(template)
        end
        @license_text
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
      !!(self.class.license_text && text.index(self.class.license_text))
    end
  end
end

Dir[File.join(File.dirname(__FILE__), 'license', '*.rb')].each do |license|
  require license
end
