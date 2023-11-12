defmodule RelaxTelegramBot.Repo.Migrations.CreateEmployeeRole do
  use Ecto.Migration

  @primary_key {:id, :integer, []}
  def change do
    create table(:employee_role) do
      add :name, :string
    end
  end
end
