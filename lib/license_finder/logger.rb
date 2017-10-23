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
      def installed package_manager, is_installed
        if String === is_installed
          log package_manager, is_installed
        elsif is_installed
          log package_manager, Logger.green("is installed")
        else
          log package_manager, Logger.red("is not installed")
        end
      end

      def prepare package_manager, can_prepare
        if String === can_prepare
          log package_manager, can_prepare
        elsif can_prepare
          log package_manager, Logger.green('preparing')
        else
          log package_manager, Logger.red('no prepare step provided')
        end
      end

      def active package_manager, is_active
        if is_active
          log package_manager, Logger.green("is active")
        else
          log package_manager, "is not active"
        end
      end

      def package package_manager, package
        dependencies = package.children
        if dependencies.empty?
          log package_manager, sprintf("package '%s' has no dependencies", package.name)
        else
          log package_manager, sprintf("package '%s' has dependencies:", package.name)
          dependencies.each do |dep|
            log package_manager, sprintf("- %s", dep)
          end
        end
      end

      def activation activation
        preamble = sprintf("package %s:", activation.package.name)
        if activation.sources.empty?
          log activation.package.class, sprintf("%s no licenses found", preamble)
        else
          activation.sources.each do |source|
            log activation.package.class, sprintf("%s found license '%s' %s", preamble, activation.license.name, source)
          end
        end
      end

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
