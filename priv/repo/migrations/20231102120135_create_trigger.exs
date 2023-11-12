defmodule RelaxTelegramBot.Repo.Migrations.AddVacationStatusTriggers do
  use Ecto.Migration

  def up do
    execute("""
      CREATE OR REPLACE FUNCTION notify_vacation() RETURNS TRIGGER AS $$
      BEGIN
        IF CURRENT_DATE = NEW.date_begin THEN
          PERFORM pg_notify('vacation_date', NEW.id::text);
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    """)

    execute("""
      CREATE TRIGGER vacation_start_trigger
      AFTER INSERT OR UPDATE ON vacation
      FOR EACH ROW
      EXECUTE FUNCTION notify_vacation();
    """)
  end

  def down do
    execute("DROP TRIGGER IF EXISTS vacation_start_trigger ON vacation;")
    execute("DROP FUNCTION IF EXISTS notify_vacation();")
  end
end
