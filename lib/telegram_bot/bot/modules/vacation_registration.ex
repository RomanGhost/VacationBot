defmodule RelaxTelegramBot.Bot.VacationReg do
  use Telegram.ChatBot
  @moduledoc false

  @session_ttl 60 * 1_000

  @impl Telegram.ChatBot
  def handle_update(%{"message" => %{"text" => text_message, "chat" => %{"id" => chat_id}}}, token, state) do
    case (state[:vacation_reg][:step]) do
      0 ->
        {date_begin, date_end} = parce_date(text_message)
        IO.puts(date_begin)
        IO.puts(date_end)
        case check_date_begin(date_begin, date_end) do
          {:ok, text, date_begin, date_end} ->
            RelaxTelegramBot.Bot.Handler.send_message(token, chat_id, text)

            new_state =  %{state | vacation_reg: %{state[:vacation_reg] | date_begin: date_begin, date_end: date_end, step: 1}}
            {:ok, new_state, @session_ttl}

          {:error, text, _, _} ->
            RelaxTelegramBot.Bot.Handler.send_message(token, chat_id, text)
            {:ok, state, @session_ttl}
        end
      1 ->
        text = "Принято!\nОтпуск успешно зарегестрирован. Жди подтверждение от руководителя!"
        RelaxTelegramBot.Bot.Handler.send_message(token, chat_id, text)

        new_state = %{state |active_state: nil, vacation_reg: %{state[:vacation_reg] | justification: text_message, step: 0}}

        user_id = RelaxTelegramBot.Request.Employee.get_user(chat_id).id
        date_begin = Timex.parse!(new_state[:vacation_reg][:date_begin], "{0D}.{0M}.{YYYY}") |> Timex.to_date
        date_end = Timex.parse!(new_state[:vacation_reg][:date_end], "{0D}.{0M}.{YYYY}")|> Timex.to_date

        RelaxTelegramBot.Request.Vacation.add_vacation(
          user_id,
          new_state[:vacation_reg][:status_id],
          date_begin,
          date_end,
          new_state[:vacation_reg][:justification]
        )

        {:ok, new_state, @session_ttl}

      _ ->
        {:error, state, @session_ttl}
    end
  end


  defp check_date_begin(date_begin, date_end) do
    case validate_date(date_begin) do
      {:ok, date} ->
        {_, date} = date
        {st, text, _, date_end} = check_date_end(date_begin, date_end)
        {st, text, date, date_end}

      {:error, reason} ->
        text = "Ошибка ввода даты: #{reason}\nПожалуйста, введите корректную конечную дату отпуска в формате DD.MM.YYYY-DD.MM.YYYY"
        {:error, text, nil, nil}
    end
  end

  defp check_date_end(date_begin, date_end) do
    case validate_date(date_end, date_begin) do
      {:ok, date} ->
        {_, date} = date
        text = "Принято! Введи обоснование отпуска"
        {:ok, text, nil, date}

      {:error, reason} ->
        text = "Ошибка ввода даты: #{reason}\nПожалуйста, введите корректную конечную дату отпуска в формате DD.MM.YYYY-DD.MM.YYYY"
        {:error, text, nil, nil}
    end
  end


  defp validate_date(text, date_begin) do
    r = Timex.parse(date_begin, "{0D}.{0M}.{YYYY}")
    case Timex.parse(text, "{0D}.{0M}.{YYYY}") do
      {:ok, date} ->
        case Timex.parse(date_begin, "{0D}.{0M}.{YYYY}") do
          {:ok, date_begin} ->
            case Date.compare(date_begin, date) do
              :lt -> {:ok, Timex.format(date, "{0D}.{0M}.{YYYY}")}
              _ -> {:error, "Дата окончания отпуска должна быть после даты начала отпуска."}
            end
          _ ->
            {:error, "Ошибка при обработке даты начала отпуска."}
        end
      _ ->
        {:error, "Дата введена неверно."}
    end
  end

  defp validate_date(text) do
    case Timex.parse(text, "{0D}.{0M}.{YYYY}") do
      {:ok, date} ->
        case Date.compare(Date.utc_today(), date) do
          :lt -> {:ok, Timex.format(date, "{0D}.{0M}.{YYYY}")}
          _ -> {:error, "Дата находится в прошлом."}
        end

      _ ->
        {:error, "Дата введена неверно."}
    end
  end

  def parce_date(text) do
    regex_pattern = ~r/^\s*(\d{2}\.\d{2}\.\d{4})\s*-\s*(\d{2}\.\d{2}\.\d{4})\s*$/

    # Применяем регулярное выражение к тексту
    match_data = Regex.run(regex_pattern, text)

    # Если есть совпадение, извлекаем данные
    if match_data do
      date_begin = hd(tl(match_data))
      date_end = hd(tl(tl(match_data)))
      {date_begin, date_end}
    else
      IO.puts "Нет совпадений."
      {:nil, :nil}
    end
  end

end
