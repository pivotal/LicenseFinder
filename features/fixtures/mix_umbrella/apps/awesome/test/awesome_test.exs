defmodule AwesomeTest do
  use ExUnit.Case
  doctest Awesome

  test "greets the world" do
    assert Awesome.hello() == :world
  end
end
