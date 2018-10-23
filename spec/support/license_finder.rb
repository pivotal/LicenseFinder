# frozen_string_literal: true

module LicenseFinder
  def self.broken_fakefs?
    RUBY_PLATFORM =~ /java/ || RUBY_VERSION =~ /^(1\.9|2\.0)/
  end
end
