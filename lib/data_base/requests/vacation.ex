defmodule RelaxTelegramBot.Request.Vacation do
  import Ecto.Query

  def add_vacation(user_id, status_id, date_begin, date_end, justification) do
    vacation_attrs = %RelaxTelegramBot.Model.Vacation{
      user_id: user_id,
      status_id: status_id,
      date_begin: date_begin,
      date_end: date_end,
      justification: justification
    }
    RelaxTelegramBot.Repo.insert(vacation_attrs)
  end

  def get_min_max_vacation_id do
    query =
      from v in RelaxTelegramBot.Model.Vacation,
        where: v.status_id in [2, 3, 4],
        select: %{
          min_id: fragment("min(?)", v.id),
          max_id: fragment("max(?)", v.id)
        }

    RelaxTelegramBot.Repo.one(query)
  end

  def update_vacation_status(vacation_id, new_status) do
    query =
      from(v in RelaxTelegramBot.Model.Vacation,
        where: v.id == ^vacation_id,
        update: [set: [status_id: ^new_status]]
      )

    RelaxTelegramBot.Repo.update_all(query, [])
  end

  def get_by_id(id) do
    query =
      from v in RelaxTelegramBot.Model.Vacation,
        where: v.id == ^id,
        select: v

    RelaxTelegramBot.Repo.one(query)
  end

end
