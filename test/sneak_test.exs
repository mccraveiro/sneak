defmodule SneakTest do
  use ExUnit.Case
  doctest Sneak

  test "greets the world" do
    assert Sneak.hello() == :world
  end
end
