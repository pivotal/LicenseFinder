# frozen_string_literal: true

module StdoutHelpers
  def capture_stderr
    orig_stderr = $stderr
    $stderr = StringIO.new

    yield

    $stderr.string
  ensure
    $stderr = orig_stderr
  end

  alias silence_stderr capture_stderr

  def capture_stdout
    orig_stdout = $stdout
    $stdout = StringIO.new

    yield

    $stdout.string
  ensure
    $stdout = orig_stdout
  end

  alias silence_stdout capture_stdout
end

RSpec.configure do |c|
  c.include(StdoutHelpers)
end
