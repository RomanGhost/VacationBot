defmodule RelaxTelegramBot.Bot.Registration do
  use Telegram.ChatBot
  @moduledoc false

  @session_ttl 60 * 1_000



  @impl Telegram.ChatBot
  def handle_update(%{"message" => %{"text" => text, "chat" => %{"id" => chat_id}}}, token, state) do
    case (state[:registration][:step] ) do
      0 ->
        # Шаг 0: Получаем имя
        {st, new_state, _} = message("Принято!\nКак твоя фамилия?:", token, chat_id, %{
          state | registration: %{state[:registration] | first_name: text, step: 1}})
        {:ok, new_state, @session_ttl}

      1 ->
        # Шаг 1: Получаем фамилию
        {st, new_state, _} = message("Принято!\nКакое твое отчество?:", token, chat_id, %{
          state | registration: %{state[:registration] | last_name: text, step: 2}})
        {:ok, new_state, @session_ttl}

      2 ->
        # Шаг 2: Получаем отчество
        keyboard = [
          ["Руководитель", "Рядовой сотрудник"]
        ]
        keyboard_markup = %{one_time_keyboard: true, keyboard: keyboard}
        {st, new_state, _} = message("Принято!\nВыбери роль в команде", keyboard_markup, token, chat_id, %{
          state | registration: %{state[:registration] | surname: text, step: 3}})
        {:ok, new_state, @session_ttl}

      3 ->
        # Все шаги пройдены, обработка завершена
        {st, new_state, _} = role_id(text,  token, chat_id, state)
        RelaxTelegramBot.Request.Employee.add_employee(
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

  defp message(response_text, markup, token, chat_id, new_state) do
    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: response_text, reply_markup: {:json, markup}
    )
    {:ok, new_state, @session_ttl}
  end

  defp message(response_text, token, chat_id, new_state) do
    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: response_text
    )
    {:ok, new_state, @session_ttl}
  end

  defp role_id("Руководитель", token, chat_id, state) do
    {st, new_state, _} = message("Регистрация завершена.\nСпасибо!", token, chat_id, %{
      state | active_state: nil, registration: %{state[:registration] | role_id: 1, step: 0}})

    {:ok, new_state, @session_ttl}
  end

  defp role_id(_text, token, chat_id, state) do
    {st, new_state, _} = message("Регистрация завершена.\nСпасибо!", token, chat_id, %{
      state | active_state: nil, registration: %{state[:registration] | role_id: 2, step: 0}})

    {:ok, new_state, @session_ttl}
  end
end
