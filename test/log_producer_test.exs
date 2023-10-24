defmodule LogProducerTest do
  use ExUnit.Case
  doctest LogProducer

  test "greets the world" do
    assert LogProducer.hello() == :world
  end
end
