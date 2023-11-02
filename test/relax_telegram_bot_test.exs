defmodule RelaxTelegramBotTest do
  use ExUnit.Case
  doctest RelaxTelegramBot

  test "greets the world" do
    assert RelaxTelegramBot.hello() == :world
  end
end
