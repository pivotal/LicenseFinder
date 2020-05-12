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

    context 'when text contains whitespace' do
      it 'normalizes whitespace to a single space' do
        text = <<~TEXT
          far                              away
          far far                                  away\nquite
        TEXT

        expected_text = 'far away far far away quite'

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

    context 'when text contains escaped quotes' do
      it 'normalizes into quotes' do
        text = 'there are some quotes \"that are a bit strange\"'
        expected_text = 'there are some quotes "that are a bit strange"'

        expect(described_class.normalize_punctuation(text)).to eq(expected_text)
      end
    end

    context 'when text contains quoted comments' do
      it 'normalizes into quotes' do
        text = <<~TEXT
          there are some thoughts
          > for example, there are some thoughts that are quoted here
          and some that are not
        TEXT

        expected_text = 'there are some thoughts for example, there are some thoughts that are quoted here and some that are not'

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
        expect(described_class.compile_to_regex(text)).to match('I am something You are something else')
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
        expect(described_class.compile_to_regex(text)).to match('This is a comma This is also a comma,')
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
        expect(described_class.compile_to_regex(text)).to match('for an apple for a loaf of bread')
      end
    end

    context 'when the text contains numerically ordered/unordered list' do
      it 'returns regex with optional alphabetically order list' do
        text = <<~TEXT
          1. for an apple
          * for a loaf of bread
        TEXT

        expected_regex = Regexp.new('(\d{1,2}.|\*)?\s*for\ an\ apple\ (\d{1,2}.|\*)?\s*for\ a\ loaf\ of\ bread')

        expect(described_class.compile_to_regex(text)).to eq(expected_regex)
        expect(described_class.compile_to_regex(text)).to match('1. for an apple * for a loaf of bread')
        expect(described_class.compile_to_regex(text)).to match('* for an apple 1. for a loaf of bread')
        expect(described_class.compile_to_regex(text)).to match('for an apple for a loaf of bread')
      end

      context 'when the text contains brackets near the unordered bullets' do
        it 'returns properly formatted regex' do
          text = <<~TEXT
            **
            * (banana bread)
            **
          TEXT

          expected_regex = Regexp.new('\*(\d{1,2}.|\*)?\s*(\d{1,2}.|\*)?\s*\(banana\ bread\)\ \*\*')

          expect(described_class.compile_to_regex(text)).to eq(expected_regex)
          expect(described_class.compile_to_regex(text)).to match('** (banana bread) **')
        end
      end

      context 'when the text contains HOLDER' do
        it 'returns properly formatted regex' do
          text = <<~TEXT
            SOME TEXT HELD BY COPYRIGHT HOLDER
          TEXT

          expected_regex = Regexp.new('SOME\ TEXT\ HELD\ BY\ COPYRIGHT\ (HOLDER|OWNER)')

          expect(described_class.compile_to_regex(text)).to eq(expected_regex)
          expect(described_class.compile_to_regex(text)).to match('SOME TEXT HELD BY COPYRIGHT OWNER')
          expect(described_class.compile_to_regex(text)).to match('SOME TEXT HELD BY COPYRIGHT HOLDER')
        end
      end
    end
  end
end
