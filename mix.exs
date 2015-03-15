defmodule SmartFarm.Mixfile do
  use Mix.Project

  def project do
    [
      app: :smartfarm,
      version: "0.1.0",
      elixir: ">= 0.13.3",
      deps: deps
    ]
  end

  # Configuration for the OTP application
  def application do
    [
      applications: [:ranch, :crypto, :cowboy, :gproc, :poison, :postgrex],
      mod: {SmartfarmServer, []},
    ]
  end

  defp deps do
    [
      {:cowboy, github: "extend/cowboy"},
      {:gproc, github: "esl/gproc"},
      {:poison, github: "devinus/poison"},
      {:postgrex, "~> 0.6"},
      {:exrm, "~> 0.14.2"}
    ]
  end
end

