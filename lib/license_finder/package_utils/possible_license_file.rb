# frozen_string_literal: true

module LicenseFinder
  class PossibleLicenseFile
    def initialize(path, options = {})
      @path = Pathname(path)
      @logger = options[:logger]
    end

    def path
      @path.to_s
    end

    def license
      License.find_by_text(text)
    end

    def text
      if @path.exist?
        @text ||= (@path.respond_to?(:binread) ? @path.binread : @path.read)
      else
        @logger.info('ERROR', "#{@path} does not exists", color: :red)
        ''
      end
    end
  end
end
