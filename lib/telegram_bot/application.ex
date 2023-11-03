defmodule RelaxTelegramBot.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    bot_config = [
      token: Application.fetch_env!(:relax_telegram_bot, :token),
      max_bot_concurrency: Application.fetch_env!(:relax_telegram_bot, :max_bot_concurrency)
    ]


    children = [
      RelaxTelegramBot.Repo,
      {Finch, name: RelaxTelegramBot.Finch},
      {Telegram.Poller, bots: [{RelaxTelegramBot.Bot.Handler, bot_config}]}
    ]

    opts = [strategy: :one_for_one, name: FrRelaxTelegramBot.Supervisor]

    Supervisor.start_link(children, opts)
  end
end
