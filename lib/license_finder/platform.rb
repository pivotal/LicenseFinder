module LicenseFinder
  module Platform
    def self.darwin?
      RUBY_PLATFORM =~ /darwin/
    end

    def self.windows?
      RUBY_PLATFORM =~ /mswin/ || RUBY_PLATFORM =~ /cygwin/ || RUBY_PLATFORM =~ /mingw/
    end
  end
end
