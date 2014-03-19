module LicenseFinder
  class License
    class Names
      attr_reader :pretty_name, :short_name

      def initialize(settings)
        @short_name  = settings.fetch(:short_name)
        @pretty_name = settings.fetch(:pretty_name, short_name)
        @other_names = settings.fetch(:other_names, [])
      end

      def matches_name?(name)
        names.map(&:downcase).include? name.to_s.downcase
      end

      private

      attr_reader :other_names

      def names
        ([short_name, pretty_name] + other_names).uniq
      end
    end
  end
end
