# frozen_string_literal: true

module LicenseFinder
  class License
    class Template
      TEMPLATE_PATH = ROOT_PATH.join('license', 'templates')

      def self.named(name)
        new TEMPLATE_PATH.join("#{name}.txt").read
      end

      attr_reader :content

      def initialize(raw_content)
        @content = Text.normalize_punctuation(raw_content)
      end
    end
  end
end
