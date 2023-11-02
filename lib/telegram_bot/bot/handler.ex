defmodule RelaxTelegramBot.Bot.Handler do
  use Telegram.ChatBot

  @session_ttl 60 * 1_000

  @impl Telegram.ChatBot
  def init(_chat) do
    {ok, state} = RelaxTelegramBot.Bot.StateNum.get_states_nil()

    {:ok, state, @session_ttl}
  end

  def handle_update(event, token, state) do
    res = message_to_text(event, event, token, state)
    {st, new_state, _} = res

    {:ok, new_state, @session_ttl}
  end

  defp message_to_text(%{"message" => %{"text" => text}}, event, token, state) do
    res = message(text, event, token, state)
    {st, new_state, _} = res

    {:ok, new_state, @session_ttl}
  end

  defp message("/" <> _command, event, token, state) do
    res = RelaxTelegramBot.Bot.Commands.handle_update(event, token, state)
    {st, new_state, _} = res

    {:ok, new_state, @session_ttl}
  end

  defp message(_text, event, token, state) do
    case state[:active_state] do
      :registration ->
        res = RelaxTelegramBot.Bot.Registration.handle_update(event, token, state)
        {st, new_state, _} = res
        {:ok, new_state, @session_ttl}

      :vacation_reg ->
        res = RelaxTelegramBot.Bot.VacationReg.handle_update(event, token, state)
        {st, new_state, _} = res
        {:ok, new_state, @session_ttl}
      _ ->
        # Логика для других состояний
        {:ok, state, @session_ttl}
    end
  end

  def send_message(token, chat_id, text) do
    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: text
    )
  end

  def send_message(token,  chat_id, text, markup) do
    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: text, reply_markup: {:json, markup}
    )
  end

end
