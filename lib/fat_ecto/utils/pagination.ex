defmodule FatEcto.Sample.Pagination do
  use FatEcto.FatPaginator,
    default_limit: Application.get_env(:data, :fat_ecto)[:default_limit],
    max_limit: Application.get_env(:data, :fat_ecto)[:max_limit]

  def paginator(query, params, repo) do
    limit = params["limit"]
    skip = params["skip"]
    skip = if is_nil(skip), do: 0, else: skip

    %{
      data_query: query,
      skip: skip,
      limit: limit,
      count_query: count_query
    } = paginate(query, skip: skip, limit: limit)

    total_records = count_records(count_query, repo)

    meta = %{
      skip: skip,
      limit: limit,
      total_records: total_records,
      pages: Float.ceil(total_records / limit) |> trunc()
    }

    {query, meta}
  end

  def paginate_get_records(query, params, repo) do
    {query, meta} = paginator(query, params, repo)
    records = repo.all(query)
    {records, meta}
  end

  def count_records(%{select: nil} = count_query, repo) do
    count_query |> repo.aggregate(:count, FatEcto.FatHelper.get_primary_keys(count_query) |> hd())
  end

  def count_records(count_query, repo) do
    repo.one(count_query)
  end
end
