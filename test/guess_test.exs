defmodule JustOneTest do
  use ExUnit.Case
  doctest JustOne

  test "greets the world" do
    assert JustOne.hello() == :world
  end
end
