defmodule RelaxTelegramBot.Model.Employee do
  use Ecto.Schema

  schema "employee" do
    field :telegram_id, :integer
    field :first_name, :string
    field :last_name, :string
    field :surname, :string
    field :role_id, :integer
  end
end
