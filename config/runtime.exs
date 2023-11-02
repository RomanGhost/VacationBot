import Config

config :relax_telegram_bot,
token: "5982857148:AAEsiXlMqJjkT0rJxTk06SD0Nd4ssJojdc0",
max_bot_concurrency: System.get_env("BOT_MAX_CONCURRENTCY", "1000") |> String.to_integer()
