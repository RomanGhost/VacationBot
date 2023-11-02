defmodule RelaxTelegramBot.Request.VacationViewer do
  import Ecto.Query

  def get_all_vacations do
    query =
      from v in RelaxTelegramBot.Model.Vacation,
        join: e in RelaxTelegramBot.Model.Employee, on: v.user_id == e.id,
        join: vs in RelaxTelegramBot.Model.VacationStatus, on: v.status_id == vs.id,
        where: v.status_id in [2, 3, 4],
        order_by: [asc: v.id],
        select: {v.id, v.date_begin, v.date_end, e.last_name, e.first_name, e.surname, vs.name}

    RelaxTelegramBot.Repo.all(query)
  end

  def get_vacation_by_id(vacation_id) do
    query =
      from v in RelaxTelegramBot.Model.Vacation,
      join: e in RelaxTelegramBot.Model.Employee, on: v.user_id == e.id,
      where: v.id == ^vacation_id,
      select: %{
        begin: v.date_begin,
        end: v.date_end,
        chat_id: e.telegram_id}

    RelaxTelegramBot.Repo.one(query)
  end


end
