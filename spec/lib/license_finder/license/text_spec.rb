# frozen_string_literal: true

require 'spec_helper'

describe LicenseFinder::License::Text do
  describe '.normalize_punctuation' do
    context 'when text contains special singe/double quotes' do
      it 'normalizes specials quotes to generic double quotes' do
        text = <<~TEXT
          ‘surrounded with special single quotes’
          “surrounded with special double quotes”
          “surrounded with special double quotes„
          «surrounded with special double quotes»
        TEXT

        expected_text = '"surrounded with special single quotes" "surrounded with special double quotes" "surrounded with special double quotes" "surrounded with special double quotes"'

        expect(described_class.normalize_punctuation(text)).to eq(expected_text)
      end
    end

    context 'when text contains whitespace tags' do
      it 'normalizes whitespace tag to a single space' do
        text = <<~TEXT
          far                              away
          far far                                  away
        TEXT

        expected_text = 'far away far far away'

        expect(described_class.normalize_punctuation(text)).to eq(expected_text)
      end
    end

    context 'when text contains multiple types of quotes' do
      it 'normalizes multiple types of quotes to generic double quotes' do
        text = <<~TEXT
          'surrounded with single quotes'
          "surrounded with double quotes"
          `surrounded with backtick`
        TEXT

        expected_text = '"surrounded with single quotes" "surrounded with double quotes" "surrounded with backtick"'

        expect(described_class.normalize_punctuation(text)).to eq(expected_text)
      end
    end
  end

  describe '.compile_to_regex' do
    context 'when the text contains placeholders' do
      it 'returns regex with wildcards' do
        text = <<~TEXT
          I am <thing>
          You are <thing2>
        TEXT

        expected_regex = Regexp.new('I\ am\ (.*)\ You\ are\ (.*)')

        expect(described_class.compile_to_regex(text)).to eq(expected_regex)
      end
    end

    context 'when the text contains commas' do
      it 'returns regex with comma optionals' do
        text = <<~TEXT
          This is a comma,
          This is also a comma,
        TEXT

        expected_regex = Regexp.new('This\ is\ a\ comma(,)?\ This\ is\ also\ a\ comma(,)?')

        expect(described_class.compile_to_regex(text)).to eq(expected_regex)
      end
    end

    context 'when the text contains alphabetically ordered list' do
      it 'returns regex with optional alphabetically order list' do
        text = <<~TEXT
          (a) for an apple
          (b) for a loaf of bread
        TEXT

        expected_regex = Regexp.new('(\([a-z]\)\s)?for\ an\ apple\ (\([a-z]\)\s)?for\ a\ loaf\ of\ bread')

        expect(described_class.compile_to_regex(text)).to eq(expected_regex)
      end
    end

    context 'when the text contains numerically ordered/unordered list' do
      it 'returns regex with optional alphabetically order list' do
        text = <<~TEXT
          1. for an apple
          * for a loaf of bread
        TEXT

        expected_regex = Regexp.new('(\d{1,2}.|\*)\s*for\ an\ apple\ (\d{1,2}.|\*)\s*for\ a\ loaf\ of\ bread')

        expect(described_class.compile_to_regex(text)).to eq(expected_regex)
      end

      context 'when the text contains brackets near the unordered bullets' do
        it 'returns properly formatted regex' do
          text = <<~TEXT
          **
          * (banana bread)
          **
          TEXT

          expected_regex = Regexp.new('\*(\d{1,2}.|\*)\s*(\d{1,2}.|\*)\s*\(banana\ bread\)\ \*\*')

          expect(described_class.compile_to_regex(text)).to eq(expected_regex)
        end
      end
    end
  end
end
