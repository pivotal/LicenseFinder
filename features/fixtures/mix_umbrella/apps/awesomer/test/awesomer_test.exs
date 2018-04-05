defmodule AwesomerTest do
  use ExUnit.Case
  doctest Awesomer

  test "greets the world" do
    assert Awesomer.hello() == :world
  end
end
