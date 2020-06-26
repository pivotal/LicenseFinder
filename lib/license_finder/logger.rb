# frozen_string_literal: true

require 'logger'

module LicenseFinder
  class Logger
    MODE_QUIET = :quiet
    MODE_INFO = :info
    MODE_DEBUG = :debug

    attr_reader :mode

    def initialize(mode = nil)
      @system_logger = ::Logger.new(STDOUT)
      @system_logger.formatter = proc do |_, _, _, msg|
        "#{msg}\n"
      end

      self.mode = mode || MODE_INFO
    end

    [MODE_INFO, MODE_DEBUG].each do |level|
      define_method level do |prefix, string, options = {}|
        msg = format('%s: %s', prefix, colorize(string, options[:color]))
        log(msg, level)
      end
    end

    private

    attr_reader :system_logger

    def colorize(string, color)
      case color
      when :red
        "\e[31m#{string}\e[0m"
      when :green
        "\e[32m#{string}\e[0m"
      when :magenta
        "\e[35m#{string}\e[0m"
      else
        string
      end
    end

    def mode=(verbose)
      @mode = verbose

      return if quiet?

      level = @mode.equal?(MODE_DEBUG) ? ::Logger::DEBUG : ::Logger::INFO
      system_logger.level = level
    end

    def log(msg, method)
      return if quiet?

      system_logger.send(method, msg)
    end

    def debug?
      @mode.equal?(MODE_DEBUG)
    end

    def quiet?
      @mode.equal?(MODE_QUIET)
    end
  end
end
