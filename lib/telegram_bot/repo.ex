defmodule RelaxTelegramBot.Repo do
  use Ecto.Repo,
  otp_app: :relax_telegram_bot,
  adapter: Ecto.Adapters.Postgres
end
