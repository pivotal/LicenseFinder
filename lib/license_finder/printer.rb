# frozen_string_literal: true

module LicenseFinder
  class Printer
    attr_reader :padding

    def initialize #:nodoc:
      @base = nil
      @mute = false
      @padding = 0
      @always_force = false
    end

    def say(message = '', color = nil, force_new_line = (message.to_s !~ /( |\t)\Z/))
      buffer = prepare_message(message, *color)
      buffer << "\n" if force_new_line && !message.to_s.end_with?("\n")

      stdout.print(buffer)
      stdout.flush
    end

    def prepare_message(message, *color)
      spaces = '  ' * padding
      spaces + set_color(message.to_s, *color)
    end

    def set_color(string, *) #:nodoc:
      string
    end

    def padding=(value)
      @padding = [0, value].max
    end

    def stdout
      $stdout
    end
  end
end
