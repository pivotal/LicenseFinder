module LicenseFinder
  module Platform
    def self.darwin?
      !(RUBY_PLATFORM =~ /darwin/).nil?
    end

    def self.windows?
      !(RUBY_PLATFORM =~ /mswin|cygwin|mingw/).nil?
    end
  end
end
