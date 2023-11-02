defmodule RelaxTelegramBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :relax_telegram_bot,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {RelaxTelegramBot.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql , "~> 3.10.2"},
      {:postgrex, "~> 0.17.3"},
      {:telegram, github: "visciang/telegram", tag: "1.1.0"},
      {:finch, "~> 0.16.0"},
      {:timex, "~> 3.7.11"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
