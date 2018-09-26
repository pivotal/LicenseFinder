# frozen_string_literal: true

module LicenseFinder
  module Activation
    # An Activation reports that a license has been activated for a package, and
    # tracks the source of that information
    Basic = Struct.new(:package, :license)

    class FromDecision < Basic
      def sources
        ['from decision']
      end
    end

    class FromSpec < Basic
      def sources
        ['from spec']
      end
    end

    class FromFiles < Basic
      def initialize(package, license, files)
        super(package, license)
        @files = files
      end

      attr_reader :files

      def sources
        files.map { |file| "from file '#{file.path}'" }
      end
    end

    class None < Basic
      def sources
        []
      end
    end
  end
end
