defmodule RelaxTelegramBot.Repo.Migrations.CreateEmployee do
  use Ecto.Migration

  @primary_key {:id, :integer, []}
  def change do
    create table(:employee) do
      add :telegram_id, :integer
      add :first_name, :string
      add :last_name, :string
      add :surname, :string
      add :role_id, references(:employee_role, on_delete: :nothing)

    end
  end
end
