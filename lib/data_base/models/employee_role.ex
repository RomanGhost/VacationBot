defmodule RelaxTelegramBot.Model.EmployeeRole do
  use Ecto.Schema

  schema "employee_role" do
    field :name, :string
  end
end
