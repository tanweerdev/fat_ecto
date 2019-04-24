defmodule FatEcto.MixProject do
  use Mix.Project

  def project do
    [
      app: :fat_ecto,
      version: "0.4.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      build_embedded: Mix.env() == :prod,
      deps: deps(),
      name: "FatEcto",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: description(),
      package: package(),
      aliases: aliases(),
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

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.1"},
      {:ecto_sql, "~> 3.1", only: :test},
      {:postgrex, "~> 0.14.1", only: :test},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_machina, "~> 2.3", only: :test}
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

  defp aliases do
    [
      "ecto.init": [],
      "ecto.create": ["ecto.create"],
      "ecto.migrate": ["ecto.migrate"],
      role_action_seeds: [],
      "ecto.setup.quite": ["ecto.create", "ecto.init", "ecto.migrate"],
      test: [
        "ecto.setup.quite",
        # "run apps/haitracker/priv/repo/role_action_seeds.exs",
        "role_action_seeds",
        "test"
      ]
    ]
  end
end
