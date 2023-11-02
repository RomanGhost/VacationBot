defmodule RelaxTelegramBot.Bot.Commands do
  use Telegram.ChatBot
  @moduledoc false

  @session_ttl 60 * 1_000

  @impl Telegram.ChatBot
  def handle_update(event, token, state) do
    {st, new_state} = command(event, token, state)
    {:ok, new_state, @session_ttl}
  end

  defp command(%{"message" => %{"text" => "/start", "chat" => %{"first_name" => first_name, "id" => chat_id}}}, token, state) do
    {st, new_state} = RelaxTelegramBot.Bot.StateNum.get_states_nil()
    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: "Привет, #{first_name}!\nПройди регистрацию: /reg\n\nЕсли ты уже зарегистрирован, то воспользуйся командой для создания отпуска /vacation"
    )
    {:ok, new_state}
  end

  defp command(%{"message" => %{"text" => "/reg", "chat" => %{"id" => chat_id}}}, token, state) do
    if RelaxTelegramBot.Request.Employee.get_user(chat_id) do
      Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Пользователь уже существует"
      )
      new_state = %{state | active_state: :nill}
      {:ok, new_state}
    else
      new_state = %{state | active_state: :registration}
      Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Начнем регистрацию, представься.\nКак тебя зовут?:"
      )
      {:ok, new_state}
    end
  end

  defp command(%{"message" => %{"text" => "/vacation", "chat" => %{"id" => chat_id}}}, token, state) do
    new_state = %{state | active_state: :vacation_reg}
    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: "Начнем заполнять отпуск\nВведи дату планируемого отпуска в формате DD.MM.YYYY:"
    )
    {:ok, new_state}
  end

  defp command(%{"message" => %{"text" => "/view_vacations", "chat" => %{"id" => chat_id}}}, token, state) do
    vacations = RelaxTelegramBot.Request.VacationViewer.get_all_vacations()

    response_text = if Enum.empty?(vacations) do
      "Отпусков пока нет"
    else
      Enum.reduce(vacations, "Отпуска сотрудников:\n", fn {index, date_begin, date_end, last_name, first_name, surname, status}, acc ->
        {_, f_date_begin} = Timex.format(date_begin, "{0D}.{0M}.{YYYY}")
        {_, f_date_end} = Timex.format(date_end, "{0D}.{0M}.{YYYY}")

        acc <>
          "#{index}. #{last_name} #{String.at(first_name, 0)}. #{String.at(surname, 0)}.\n" <>
          "Дата: #{f_date_begin} - #{f_date_end}\n" <>
          "Статус: #{status}\n\n"
      end)
    end

    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: response_text
    )
    {:ok, state}
  end

  defp command(%{"message" => %{"text" => "/view_employee", "chat" => %{"id" => chat_id}}}, token, state) do
    employees = RelaxTelegramBot.Request.Employee.get_all_employee()

    response_text = if Enum.empty?(employees) do
      "Сотрудников нет"
    else
      Enum.reduce(employees, "Список сотрудников:\n", fn {id, last_name, first_name, surname, role_name}, acc ->
        acc <>
          "#{id}. #{last_name} #{String.at(first_name, 0)}. #{String.at(surname, 0)}.\n" <>
          "Роль: #{role_name}\n\n"
      end)
    end

    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: response_text
    )
    {:ok, state}
  end



  defp command(%{"message" => %{"text" => "/state", "chat" => %{"id" => chat_id}}}, token, state) do
    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: "Текущее состояние: #{state[:active_state]}"
    )
    {:ok, state}
  end

  defp command(%{"message" => %{"text" => text, "chat" => %{"id" => chat_id}}}, token, state) do
    {command_text, id} = parse_string(text)


    if(RelaxTelegramBot.Request.Employee.has_role_boss?(chat_id)) do
      command_adm(command_text, id, chat_id, token, state)
    else
      command_usr(command_text, id, chat_id, token, state)
    end
    {:ok, state}
  end

  defp parse_string(str) do
    tokens = String.split(str)

    case Enum.count(tokens) do
      count when count >= 2 ->
        {command, id} = {Enum.at(tokens, 0), Enum.at(tokens, 1)}
        id = String.to_integer(id)
        {command, id}

      _ ->
        command = Enum.at(tokens, 0)
        {command, -1}
    end
  end

  defp command_adm("/approve", id, chat_id, token, state) do
    res = change_vacation(id, 3)

    case (res) do
      {:ok, database} ->
        {_, date_begin} = Timex.format(database.begin, "{0D}.{0M}.{YYYY}")
        {_, date_end} = Timex.format(database.end, "{0D}.{0M}.{YYYY}")

        Telegram.Api.request(
        token, "sendMessage", chat_id: database.chat_id,
        text: "Отпуск #{date_begin} - #{date_end}\nОтклонен"
        )

        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Отпуск одобрен"
        )
      {:error, nil} ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Отпуск не найден"
        )
      _ ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Что-то пошло не так"
        )
    end

    {:ok, state}
  end

  defp command_adm("/refuse", id, chat_id, token, state) do
    res = change_vacation(id, 1)

    case (res) do
      {:ok, database} ->
        {_, date_begin} = Timex.format(database.begin, "{0D}.{0M}.{YYYY}")
        {_, date_end} = Timex.format(database.end, "{0D}.{0M}.{YYYY}")

        Telegram.Api.request(
        token, "sendMessage", chat_id: database.chat_id,
        text: "Отпуск #{date_begin} - #{date_end}\nОтклонен"
        )
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Отпуск отклонен"
        )
      {:error, nil} ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Отпуск не найден"
        )
      _ ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Что-то пошло не так"
        )
    end

    {:ok, state}
  end

  defp command_usr("/cancel", id, chat_id, token, state) do
    res = change_vacation(id, 1)

    case (res) do
      {:ok, database} ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Отпуск отменен"
        )
      {:error, nil} ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Отпуск не найден"
        )
      _ ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Что-то пошло не так"
        )
    end

    {:ok, state}
  end

  defp command_amd("/fire", id, chat_id, token, state) do
    user = RelaxTelegramBot.Request.Employee.user_by_id(id)
    res = RelaxTelegramBot.Request.Employee.delete(user.telegram_id)
    case (res) do
      {:ok, text} ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Сотрудник спешно уволен"
        )
      {:error, text} ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Ошибка увольнения. Тебя нет в команде"
        )
      _ ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Что-то пошло не так"
        )
    end

    {:ok, state}
  end

  defp command_adm("/dismissal", _id, chat_id, token, state) do
    res = RelaxTelegramBot.Request.Employee.delete(chat_id)
    case (res) do
      {:ok, text} ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Успешно уволен"
        )
      {:error, text} ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Ошибка увольнения. Тебя нет в команде"
        )
      _ ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Что-то пошло не так"
        )
    end

    {:ok, state}
  end

  defp command_usr("/dismissal", _id, chat_id, token, state) do
    res = RelaxTelegramBot.Request.Employee.delete(chat_id)
    case (res) do
      {:ok, text} ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Успешно уволен"
        )
      {:error, text} ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Ошибка увольнения. Тебя нет в команде"
        )
      _ ->
        Telegram.Api.request(
        token, "sendMessage", chat_id: chat_id,
        text: "Что-то пошло не так"
        )
    end

    {:ok, state}
  end

  defp command_usr(_command, id, chat_id, token, state) do
    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: "Недостаточно прав.\nВы не являетесь руководителем"
      )

    {:ok, state}
  end

  defp command_adm(_command, id, chat_id, token, state) do
    Telegram.Api.request(
      token, "sendMessage", chat_id: chat_id,
      text: "Неизвестная команда"
      )

    {:ok, state}
  end

  defp change_vacation(id, status_id) do
    res = RelaxTelegramBot.Request.Vacation.get_min_max_vacation_id()
    min_id = res.min_id
    max_id = res.max_id
    if (min_id <= id && id <= max_id) do
      RelaxTelegramBot.Request.Vacation.update_vacation_status(id, status_id)
      res = RelaxTelegramBot.Request.VacationViewer.get_vacation_by_id(id)

      {:ok, res}
    else

      {:error, nil}
    end
  end


end