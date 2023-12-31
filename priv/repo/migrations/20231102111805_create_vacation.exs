defmodule RelaxTelegramBot.Repo.Migrations.CreateVacation do
  use Ecto.Migration

  @primary_key {:id, :integer, []}

  def change do
    create table(:vacation) do
      add :user_id, references(:employee, on_delete: :delete_all)
      add :status_id, references(:vacation_status, on_delete: :nothing)
      add :date_begin, :date
      add :date_end, :date
      add :justification, :string

      timestamps()

    end

    create index(:vacation, [:user_id])
  end
end
