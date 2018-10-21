defmodule FatEcto.FatQuery do
  @moduledoc """
  Entry Point for building queries.

  `import` or `alias` it inside your module
  """

  @default_query_opts %{
    "$find" => "$all",
    "$where" => nil,
    # TODO: $max and $min should be part of select as in example docs
    "$max" => nil,
    "$min" => nil,
    "$include" => nil,
    "$select" => nil,
    "$order" => nil,
    # TODO: $group should be part of select
    "$group" => nil,
    "$skip" => 0,
    "$limit" => Application.get_env(:fat_ecto, :repo)[:default_limit]
  }

  @repo Application.get_env(:fat_ecto, :repo)[:query_repo]
  use FatEcto.FatPaginator, repo: @repo

  # import FatEcto.FatQuery.FatWhere, only: [build_where: 2] # import and use like this if without defmacro
  # import FatEcto.FatQuery.FatOrderBy, only: [build_order_by: 2]
  # import FatEcto.FatQuery.FatInclude, only: [build_include: 3]
  # import FatEcto.FatQuery.FatSelect, only: [build_select: 3]
  # import FatEcto.FatQuery.FatJoin, only: [build_join: 2]
  # import FatEcto.FatQuery.FatGroupBy, only: [build_group_by: 2]

  import Ecto.Query
  use FatEcto.FatQuery.FatWhere
  use FatEcto.FatQuery.FatOrderBy
  use FatEcto.FatQuery.FatInclude
  use FatEcto.FatQuery.FatSelect
  use FatEcto.FatQuery.FatJoin
  use FatEcto.FatQuery.FatGroupBy
  # TODO: Should return {:ok, query}
  @doc """
  Call the `respective query method` depending on the params.
  ## Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map
  ## Examples
      query_opts =%{
        "$find" => "$all",
        "$include" => %{"assoc_model" => %{"$limit" => 3, "$join" => "$inner"}},
        "$select" => %{"$fields" => ["first_name", "last_name"], "assoc_model" => ["public_name"]},
        "$skip" => 0,
        "$where" => %{"id" => 10}
      }

      iex> build(queryable, query_opts)
           #Ecto.Query<from q in queryable, join: a in assoc(q, :assoc_model),
           where: q.id == ^10,
           select: map(q, [:first_name, :last_name, {:assoc_model, [:public_name]}]),
           preload: [assoc_model: #Ecto.Query<from a in assoc_model, limit: ^3, offset: ^0>]>

  ## Options

    - `$find`- To fetch all the results from database.
    - `include`- Include the assoc_model and also define the limit and join type.
    - `select`- select the fields from queryable and the assoc_model as well.
    - `skip`- Skip records.
    - `where`- Added the where attribute in the query .







  """
  # TODO: Add docs and examples for ex_doc
  def build(queryable, query_opts) do
    model =
      if is_atom(queryable) do
        queryable
      else
        {_table, model} = queryable.from
        model
      end

    build_query(queryable, query_opts, model)
  end

  defp build_query(queryable, opts, model) do
    # TODO: LIMP: first confirm the field exist in the schema
    queryable
    |> build_select(opts["$select"], model)
    |> build_where(opts["$where"])
    |> build_join(opts["$join"], "$join")
    |> build_join(opts["$right_join"], "$right_join")
    |> build_join(opts["$left_join"], "$left_join")
    |> build_join(opts["$inner_join"], "$inner_join")
    |> build_join(opts["$full_join"], "$full_join")
    |> build_include(opts["$include"], model)
    |> build_order_by(opts["$order"])
    |> build_group_by(opts["$group"])
  end

  # TODO: Add docs and examples for ex_doc
  def fetch(queryable, query_opts) do
    opts = Ex.MapUtils.deep_merge(@default_query_opts, query_opts)
    queryable = FatEcto.FatQuery.build(queryable, opts)

    case opts["$find"] do
      "$one" ->
        {:ok, @repo.one(Ecto.Query.limit(queryable, 1))}

      "$all" ->
        {:ok, new(queryable, skip: opts["$skip"], limit: opts["$limit"])}

      nil ->
        {:error, "Method not found"}

      _ ->
        {:error, "Method not found"}
    end
  end
end
