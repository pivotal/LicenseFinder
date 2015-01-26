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
        log package_manager, sprintf("%s active", (is_active ? "is" : "not"))
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
