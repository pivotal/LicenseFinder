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
      def log prefix, string
        raise NotImplementedError, "#log must be implemented"
      end
    end

    def self.green string
      colorize 32, string
    end

    def self.red string
      colorize 31, string
    end

    def self.colorize color_code, string
      "\e[#{color_code}m#{string}\e[0m"
    end

    class Quiet < Base
      def log prefix, string
      end
    end

    class Progress < Base
      def log prefix, string
        print(".") && $stdout.flush
      end
    end

    class Verbose < Base
      def log prefix, string
        printf("%s: %s\n", prefix, string)
      end
    end

    Default = Quiet
  end
end
