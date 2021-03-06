defmodule Sneak.Mixfile do
  use Mix.Project

  def project do
    [
      app: :sneak,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      applications: [:httpoison, :floki],
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:floki, "~> 0.18.0"},
      {:httpoison, "~> 0.13"}
    ]
  end
end
