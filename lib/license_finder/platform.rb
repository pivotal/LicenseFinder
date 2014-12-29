module LicenseFinder
  module Platform
    def self.java?
      RUBY_PLATFORM =~ /java/
    end

    def self.darwin?
      RUBY_PLATFORM =~ /darwin/
    end
  end
end

