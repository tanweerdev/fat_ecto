defmodule FatEcto.Sample.V2Pagination do
  use FatEcto.FatV2Paginator,
    default_limit: 10,
    repo: FatEcto.Repo,
    max_limit: 100
end
