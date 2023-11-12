defmodule RelaxTelegramBot.Repo.Migrations.CreateVacationStatus do
  use Ecto.Migration

  @primary_key {:id, :integer, []}
  def change do
    create table(:vacation_status) do
      add :name, :string
    end
  end
end
