module LicenseFinder
  module Platform
    def self.darwin?
      RUBY_PLATFORM =~ /darwin/
    end
  end
end

