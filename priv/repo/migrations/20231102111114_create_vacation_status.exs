defmodule RelaxTelegramBot.Repo.Migrations.CreateVacationStatus do
  use Ecto.Migration

  @primary_key {:id, :integer, []}
  def change do
    create table(:vacation_status) do
      add :name, :string
    end

    execute("INSERT INTO vacation_status (name) VALUES ('отказано в отпуске')")
    execute("INSERT INTO vacation_status (name) VALUES ('ожидание подтверждения')")
    execute("INSERT INTO vacation_status (name) VALUES ('отпуск подтвержден')")
    execute("INSERT INTO vacation_status (name) VALUES ('в отпуске')")
    execute("INSERT INTO vacation_status (name) VALUES ('отпуск исполнен')")

  end
end
