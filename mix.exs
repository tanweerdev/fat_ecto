defmodule FatEcto.MixProject do
  use Mix.Project

  def project do
    [
      app: :fat_ecto,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "FatEcto",
      source_url: "https://github.com/tanweerdev/fat_ecto"
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
      {:csv, "~> 2.1"},
      {:ecto, "~> 3.0"},
      {:sweet_xml, "~> 0.6.5"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:elixir_utils, github: "tanweerdev/elixir_utils"},
      {:earmark, "~> 1.2", only: :dev}
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end
end
