defmodule FatEcto.Sample.Pagination do
  use FatEcto.FatPaginator,
    default_limit: 10,
    repo: FatEcto.Repo,
    max_limit: 100
end
