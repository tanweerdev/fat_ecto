defmodule FatEcto.MixProject do
  use Mix.Project

  def project do
    [
      app: :fat_ecto,
      version: "0.2.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      name: "FatEcto",
      description: description(),
      package: package(),
      docs: [
        # The main page in the docs
        main: "readme",
        # logo: "path/to/logo.png",
        extras: ["README.md"]
      ],
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
      {:ecto, "~> 2.2"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:earmark, "~> 1.2", only: :dev}
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
    ]
  end

  defp description() do
    "fat_ecto provides methods for dynamically building queries according to the parameters it receive."
  end

  defp package() do
    [
      # These are the default files included in the package
      files: ~w(lib .formatter.exs mix.exs README*),
      licenses: ["Apache 2.0"],
      links: %{
        "GitHub" => "https://github.com/tanweerdev/fat_ecto",
        "Docs" => "https://hexdocs.pm/fat_ecto/"
      }
    ]
  end
end
