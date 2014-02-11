module LicenseFinder
  class License
    Matcher = Struct.new(:regexp) do
      def self.from_template(template)
        from_text(template.content)
      end

      def self.from_text(text)
        new(Text.compile_to_regex(text))
      end

      def matches_text?(text)
        !!(Text.normalize_punctuation(text) =~ regexp)
      end
    end
  end
end
