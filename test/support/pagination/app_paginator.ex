defmodule FatEcto.Sample.Pagination do
  use FatEcto.Pagination.Paginator,
    default_limit: 10,
    repo: FatEcto.Repo,
    max_limit: 100
end
