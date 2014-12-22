module LicenseFinder
  class License
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
  end
end
