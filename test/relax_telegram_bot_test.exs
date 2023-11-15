defmodule RelaxTelegramBotTest do
  use ExUnit.Case

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
  end

end
