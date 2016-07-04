defmodule Todo.Mixfile do
  use Mix.Project

  def project do
    [app: :todo,
     version: "0.0.1",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test, "coveralls.post": :test, "coveralls.html": :test],
    ]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    rest = if(Mix.env == :test, do: [], else: [mod: {Todo.Application, []}])
    [applications: [:logger, :gproc, :cowboy, :plug]] ++ rest
  end

  defp deps do
    [
      {:gproc, "0.3.1"},
      {:cowboy, "1.0.0"},
      {:plug, "1.1.6"},
      {:hackney, "1.6.0"},
      {:excoveralls, "~> 0.5", only: :test},
      {:meck, "~> 0.8.2", only: :test},
      {:mock, "~> 0.1.1", only: :test},
      {:httpoison, "~> 0.9.0", only: :test},
      {:inch_ex, only: :docs}
    ]
  end
end
