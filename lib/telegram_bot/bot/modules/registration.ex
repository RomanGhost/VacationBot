defmodule RelaxTelegramBot.Bot.Registration do
  use Telegram.ChatBot
  @moduledoc false

  @session_ttl 60 * 1_000



  @impl Telegram.ChatBot
  def handle_update(%{"message" => %{"text" => text, "chat" => %{"id" => chat_id}}}, token, state) do
    case (state[:registration][:step] ) do
      0 ->
        # Шаг 0: Получаем имя
        text = "Принято!\nКак твоя фамилия?:"
        RelaxTelegramBot.Bot.Handler.send_message(token, chat_id, text)
        new_state = %{state | registration: %{state[:registration] | first_name: text, step: 1}}

        {:ok, new_state, @session_ttl}

      1 ->
        # Шаг 1: Получаем фамилию
        text = "Принято!\nКакое твое отчество?:"
        RelaxTelegramBot.Bot.Handler.send_message(token, chat_id, text)
        new_state = %{state | registration: %{state[:registration] | last_name: text, step: 2}}

        {:ok, new_state, @session_ttl}

      2 ->
        # Шаг 2: Получаем отчество
        keyboard = [
          ["Руководитель", "Рядовой сотрудник"]
        ]
        keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}
        text = "Принято!\nВыбери роль в команде"
        RelaxTelegramBot.Bot.Handler.send_message(token, chat_id, text, keyboard_markup)
        new_state = %{state | registration: %{state[:registration] | surname: text, step: 3}}
        {:ok, new_state, @session_ttl}

      3 ->
        # Все шаги пройдены, обработка завершена
        text = "Регистрация завершена.\nСпасибо!"
        RelaxTelegramBot.Bot.Handler.send_message(token, chat_id, text)


        {st, new_state, _} = role_id(text, state)
        RelaxTelegramBot.Request.Employee.add(
          chat_id,
          new_state[:registration][:first_name],
          new_state[:registration][:last_name],
          new_state[:registration][:surname],
          new_state[:registration][:role_id]
          )
        {:ok, new_state, @session_ttl}

      _ ->
        {:error, state, @session_ttl}
    end
  end

  defp role_id("Руководитель", state) do
    new_state = %{state | active_state: nil, registration: %{state[:registration] | role_id: 1, step: 0}}

    {:ok, new_state, @session_ttl}
  end

  defp role_id(_text, state) do
    new_state = %{state | active_state: nil, registration: %{state[:registration] | role_id: 2, step: 0}}

    {:ok, new_state, @session_ttl}
  end
end
