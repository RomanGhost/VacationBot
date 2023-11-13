import Config

config :logger, :console, metadata: [:bot]

config :relax_telegram_bot, RelaxTelegramBot.Repo,
  database: System.get_env("DATABASE_NAME"),
  username: System.get_env("DATABASE_USERNAME"),
  password: System.get_env("DATABASE_PASSWORD"),
  hostname: System.get_env("DATABASE_HOSTNAME"),
  pool_size: 10

config :relax_telegram_bot, RelaxTelegramBot.Scheduler,
  jobs: [
    {"@daily", fn -> RelaxTelegramBot.Service.handle_task() end}
  ]

config :relax_telegram_bot, ecto_repos: [RelaxTelegramBot.Repo]
config :tesla, :adapter, {Tesla.Adapter.Finch, name: RelaxTelegramBot.Finch}
