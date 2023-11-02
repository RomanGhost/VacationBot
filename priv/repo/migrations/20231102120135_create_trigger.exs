defmodule RelaxTelegramBot.Repo.Migrations.AddVacationStatusTriggers do
  use Ecto.Migration

  def up do
    execute("""
      CREATE OR REPLACE FUNCTION update_status_on_start()
      RETURNS TRIGGER AS $$
      BEGIN
        IF NEW.status_id = 3 AND CURRENT_DATE = NEW.date_begin THEN
          NEW.status_id = 4;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    """)

    execute("""
      CREATE TRIGGER update_status_on_start_trigger
      BEFORE INSERT OR UPDATE ON vacation
      FOR EACH ROW EXECUTE FUNCTION update_status_on_start();
    """)

    execute("""
      CREATE OR REPLACE FUNCTION update_status_on_end()
      RETURNS TRIGGER AS $$
      BEGIN
        IF NEW.status_id = 4 AND CURRENT_DATE = NEW.date_end THEN
          NEW.status_id = 5;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
    """)

    execute("""
      CREATE TRIGGER update_status_on_end_trigger
      BEFORE INSERT OR UPDATE ON vacation
      FOR EACH ROW EXECUTE FUNCTION update_status_on_end();
    """)
  end

  def down do
    execute("DROP TRIGGER IF EXISTS update_status_on_start_trigger ON vacation;")
    execute("DROP FUNCTION IF EXISTS update_status_on_start();")
    execute("DROP TRIGGER IF EXISTS update_status_on_end_trigger ON vacation;")
    execute("DROP FUNCTION IF EXISTS update_status_on_end();")
  end
end
