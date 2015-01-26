module LicenseFinder
  module Activation
    # An Activation reports that a license has been activated for a package, and
    # tracks how that information was established
    Basic = Struct.new(:package, :license) do
      def log(logger)
        sources.each do |source|
          log_package(logger, "found license '#{license.name}' #{source}")
        end
      end

      private

      def log_package(logger, text)
        logger.log(
          package.class,
          "package #{package.name}: #{text}"
        )
      end
    end

    class FromDecision < Basic
      def sources
        ["from decision"]
      end
    end

    class FromSpec < Basic
      def sources
        ["from spec"]
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

      def log(logger)
        log_package(logger, "no licenses found")
      end
    end
  end
end
