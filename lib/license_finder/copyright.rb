# frozen_string_literal: true

# encode: utf-8

module LicenseFinder
  class Copyright
    COPYRIGHT_EXPRESSION = %r{
      (?!.*(?:\{|\}|\);))
      (?:
        (copyright|&copy;|\(c\)|\&\#(?:169|xa9;)|©)[\u0020\t]* # copyright detection
        (?:(&copy;|\(c\)|\&\#(?:169|xa9;)|©)[\u0020\t]+)? # possible additional copyright sign
      )
      (?:
        ((?:([0-9]{2}|\bpresent\b|\bby\b)[^\w\n]*)*) # possible year notation
        (([\u0020\t,\w\<\>@\-\[\]\(\)\:\/]|\.[a-z\.])*) # copyright owner
      )
    }ix.freeze

    def self.find_by_text(text)
      cleaned_text = text.force_encoding('UTF-8')
      cleaned_text = text.encode('UTF-8', invalid: :replace, undef: :replace) unless cleaned_text.valid_encoding?

      match = cleaned_text.match COPYRIGHT_EXPRESSION
      return new(match[0].strip, match[5].strip, text) if match

      nil
    end

    attr_reader :copyright, :owners, :text

    def initialize(copyright, owners = nil, text = nil)
      @copyright = copyright
      @owners = owners
      @text = text
    end

    def to_s
      @copyright
    end
  end
end
