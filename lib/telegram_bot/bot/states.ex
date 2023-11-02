defmodule RelaxTelegramBot.Bot.StateNum do
  use Telegram.ChatBot

  @states %{
    :active_state => nil,
    :registration => %{first_name: nil, last_name: nil, surname: nil, role_id: nil, step: 0},
    :vacation_reg => %{status_id: 2, date_begin: nil, date_end: nil, justification: nil, step: 0}
  }

  def get_states_nil() do
    new_state = @states
    {:ok, new_state}
  end


end
