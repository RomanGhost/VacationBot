defmodule RelaxTelegramBot.Request.Employee do
  import Ecto.Query

  def add(telegram_id, first_name, last_name, surname, role_id) do
    employee_attrs = %RelaxTelegramBot.Model.Employee{
      telegram_id: telegram_id,
      first_name: first_name,
      last_name: last_name,
      surname: surname,
      role_id: role_id
    }
    RelaxTelegramBot.Repo.insert(employee_attrs)
  end

  def get_user(telegram_id) do
    RelaxTelegramBot.Repo.get_by(RelaxTelegramBot.Model.Employee, telegram_id: telegram_id)
  end

  def has_role_boss?(telegram_id) do
    employee = get_user(telegram_id)
    if employee && employee.role_id == 1 do
      true
    else
      false
    end
  end

  def get_all_employee do
    query =
      from e in RelaxTelegramBot.Model.Employee,
        join: r in RelaxTelegramBot.Model.EmployeeRole, on: e.role_id == r.id,
        order_by: [asc: e.id],
        select: {e.id, e.last_name, e.first_name, e.surname, r.name}

    RelaxTelegramBot.Repo.all(query)
  end


  def user_by_id(id) do
    RelaxTelegramBot.Repo.get_by(RelaxTelegramBot.Model.Employee, telegram_id: id)
  end

  def delete(telegram_id) do
    case get_user(telegram_id) do
      nil ->
        {:error, "User not found"}

      %RelaxTelegramBot.Model.Employee{} = employee ->
        RelaxTelegramBot.Repo.delete(employee)
        {:ok, "User deleted successfully"}
    end
  end
end
