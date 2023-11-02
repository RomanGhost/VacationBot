defmodule RelaxTelegramBot.Repo.Migrations.CreateEmployeeRole do
  use Ecto.Migration

  @primary_key {:id, :integer, []}
  def change do
    create table(:employee_role) do
      add :name, :string
    end

    # Заполнение таблицы начальными данными
    execute("INSERT INTO employee_role (name) VALUES ('руководитель')")
    execute("INSERT INTO employee_role (name) VALUES ('сотрудник')")
  end
end
