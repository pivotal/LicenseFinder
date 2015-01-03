module StdoutHelpers
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
