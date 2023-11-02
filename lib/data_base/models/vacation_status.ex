defmodule RelaxTelegramBot.Model.VacationStatus do
  use Ecto.Schema

  schema "vacation_status" do
    field :name, :string
  end
end
