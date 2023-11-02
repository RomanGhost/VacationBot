defmodule RelaxTelegramBot.Model.Vacation do
  use Ecto.Schema

  schema "vacation" do
    field :user_id, :integer
    field :status_id, :integer
    field :date_begin, :date
    field :date_end, :date
    field :justification, :string


    #statuses:
    # 1 - отпуск не подтвержден
    # 2 - ожидание результата от руководителя
    # 3 - отпуск подтвержден
    # 4 - в отпуске
    # 5 - отпуск исполнен
  end
end
