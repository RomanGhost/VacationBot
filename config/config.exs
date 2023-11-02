import Config

config :logger, :console, metadata: [:bot]

config :relax_telegram_bot, RelaxTelegramBot.Repo,
  database: "VacationDep",
  username: "userelixir",
  password: "119824",
  hostname: "localhost",
  pool_size: 10

config :relax_telegram_bot, ecto_repos: [RelaxTelegramBot.Repo]
config :tesla, :adapter, {Tesla.Adapter.Finch, name: RelaxTelegramBot.Finch}
