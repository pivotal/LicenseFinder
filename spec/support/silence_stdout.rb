module SilenceStdout
  def silence_stdout
    orig_stdout = $stdout
    $stdout = File.open("/dev/null", "w")
    yield
  ensure
    $stdout = orig_stdout
  end
end

RSpec.configure do |c|
  c.include(SilenceStdout)
end
