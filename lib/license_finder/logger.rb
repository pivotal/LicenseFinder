module LicenseFinder
  module Logger
    def self.new(options = {})
      klass = if options[:quiet]
                Quiet
              elsif options[:debug]
                Verbose
              else
                Progress
              end
      klass.new
    end

    def self.colorize(string, color)
      case color
      when :red
        "\e[31m#{string}\e[0m"
      when :green
        "\e[32m#{string}\e[0m"
      else
        string
      end
    end

    class Base
      def log(_prefix, _string, _options = {})
        raise NotImplementedError, '#log must be implemented'
      end
    end

    class Quiet < Base
      def log(prefix, string, options = {}); end
    end

    class Progress < Base
      def log(_prefix, _string, _options = {})
        print('.') && $stdout.flush
      end
    end

    class Verbose < Base
      def log(prefix, string, options = {})
        printf("%s: %s\n", prefix, Logger.colorize(string, options[:color]))
      end
    end

    Default = Quiet
  end
end
