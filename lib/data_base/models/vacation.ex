defmodule RelaxTelegramBot.Model.Vacation do
  use Ecto.Schema

  schema "vacation" do
    field :user_id, :integer
    field :status_id, :integer
    field :date_begin, :date
    field :date_end, :date
    field :justification, :string
  end
end
