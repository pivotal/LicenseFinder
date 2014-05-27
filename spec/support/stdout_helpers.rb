module StdoutHelpers
  def silence_stdout
    orig_stdout = $stdout
    $stdout = File.open("/dev/null", "w")
    yield
  ensure
    $stdout = orig_stdout
  end

  def capture_stdout
    orig_stdout = $stdout
    stdout_reader, $stdout = IO.pipe

    yield

    $stdout.close
    stdout_reader.read
  ensure
    $stdout = orig_stdout
  end
end

RSpec.configure do |c|
  c.include(StdoutHelpers)
end
