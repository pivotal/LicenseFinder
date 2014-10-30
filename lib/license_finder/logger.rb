module LicenseFinder
  module Logger
    def self.new options={}
      klass = if options[:quiet]
                Quiet
              elsif options[:debug]
                Verbose
              else
                Progress
              end
      klass.new
    end

    class Base
      def active package_manager, is_active
        log package_manager, sprintf("%s active\n", (is_active ? "is" : "not"))
      end

      def log prefix, string
        raise NotImplementedError, "#log must be implemented"
      end
    end

    class Quiet < Base
      def log prefix, string
      end
    end

    class Progress < Base
      def log prefix, string
        STDOUT.print(".") && STDOUT.flush
      end
    end

    class Verbose < Base
      def log prefix, string
        STDOUT.printf("%s: %s", prefix, string)
      end
    end

    Default = Quiet
  end
end
