defmodule Reuniclus.MixProject do
  use Mix.Project

  def project do
    [
      app: :reuniclus,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {Reuniclus, []},
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:nostrum, github: "Kraigie/nostrum"},
      {:ecto, "~> 3.8"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_sql, "~> 3.0-rc.1"},
      {:timex, "~> 3.0"},
      {:cachex, "~> 3.6"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
