module LicenseFinder
  module Platform
    def self.darwin?
      RUBY_PLATFORM =~ /darwin/
    end

    def self.windows?
      RUBY_PLATFORM =~ /mswin|cygwin|mingw/
    end
  end
end
