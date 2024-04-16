import Config

config :fat_ecto,
  ecto_repos: [FatEcto.Repo]

config :fat_ecto, FatEcto.Repo,
  username: "postgres",
  password: "postgres",
  database: "fat_ecto_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox,
  log: false
