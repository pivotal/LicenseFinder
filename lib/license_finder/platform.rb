# frozen_string_literal: true

module LicenseFinder
  module Platform
    def self.darwin?
      RUBY_PLATFORM =~ /darwin/
    end

    def self.windows?
      # SO: What is the correct way to detect if ruby is running on Windows?,
      # cf. https://stackoverflow.com/a/21468976/2592915
      Gem.win_platform? || RUBY_PLATFORM =~ /mswin|cygwin|mingw/
    end
  end
end
