
defmodule Awesome.Mixfile do
  use Mix.Project

  def project do
    [app: :awesome,
     version: "0.1.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: []]
  end

  defp deps do
    [{:fs, "0.9.1"},
     {:uuid, "1.1.5"},
     {:plug, "1.7.2"}]
  end
end
