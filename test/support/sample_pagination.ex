defmodule FatEcto.Sample.Pagination do
  use FatEcto.FatPaginator,
    default_limit: 10,
    max_limit: 100

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

    pages = (total_records / limit) |> Float.ceil() |> trunc()

    meta = %{
      skip: skip,
      limit: limit,
      total_records: total_records,
      pages: pages
    }

    {query, meta}
  end

  def paginate_get_records(query, params, repo) do
    {query, meta} = paginator(query, params, repo)
    records = repo.all(query)
    {records, meta}
  end

  def count_records(%{select: nil} = count_query, repo) do
    repo.aggregate(count_query, :count, count_query |> FatEcto.FatHelper.get_primary_keys() |> hd())
  end

  def count_records(count_query, repo) do
    repo.one(count_query)
  end
end
