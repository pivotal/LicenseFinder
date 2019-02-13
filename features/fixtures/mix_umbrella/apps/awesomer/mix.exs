defmodule Awesomer.MixProject do
  use Mix.Project

  def project do
    [
      app: :awesomer,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:awesome, in_umbrella: true},
      {:uuid, "1.1.5"},
      {:plug, "1.7.2"}
    ]
  end
end
