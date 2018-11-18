defmodule FatEcto.FatQuery do
  @moduledoc """
  Entry Point module for building queries.

  `import` or `alias` it inside your module.
  """

  @query_param_defaults %{
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
  use FatEcto.FatQuery.FatAggregate
  # TODO: Should return {:ok, query}
  @doc """
  Call the `respective query method` depending on the params.
  ## Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map
  ## Examples
      iex> query_opts = %{
      ...>   "$select" => %{
      ...>     "$fields" => ["name", "location", "rating"],
      ...>     "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>   "$order" => %{"id" => "$desc"},
      ...>   "$where" => %{"rating" => 4},
      ...>   "$group" => "nurses",
      ...>   "$include" => %{
      ...>       "fat_doctors" => %{
      ...>           "$include" => ["fat_patients"],
      ...>           "$where" => %{"name" => "ham"},
      ...>           "$order" => %{"id" => "$desc"},
      ...>           "$join" => "$right"
      ...>          }
      ...>     },
      ...>   "$right_join" => %{
      ...>      "fat_rooms" => %{
      ...>        "$on_field" => "id",
      ...>        "$on_join_table_field" => "hospital_id",
      ...>        "$select" => ["beds", "capacity", "level"],
      ...>        "$where" => %{"incharge" => "John"}
      ...>       }
      ...>     }
      ...>  }
      iex> build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, right_join: f2 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, where: f1.incharge == ^"John" and ^true, group_by: [f0.nurses], order_by: [desc: f0.id], select: merge(map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), %{^:fat_rooms => map(f1, [:beds, :capacity, :level])}), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.name == ^"ham" and ^true, order_by: [desc: f.id], limit: ^10, offset: ^0, preload: [:fat_patients]>]>




  ## Options

    - `$include`- Include the assoication model `doctors`.
    - `$include: :fat_patients`- Include the assoication `patients`. Which has association with `doctors`.
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$where`- Added the where attribute in the query.
    - `$group`- Added the group_by attribute in the query.
    - `$order`- Sort the result based on the order attribute.
    - `$right_join`- Specify the type of join.
    - `$on_field`- Specify the field for join.
    - `$on_join_table_field`- Specify the field for join in the joining table.
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
    |> build_aggregate(opts["$aggregate"])
    |> build_group_by(opts["$group"])
  end

  # TODO: Add docs and examples for ex_doc
  @doc """
     Fetch the result from the repo based on the query params.

  ## Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map

  ## Examples
      iex> query_opts = %{
      ...>  "$find" => "$all",
      ...>  "$select" => %{"$fields" => ["name", "rating"], "fat_rooms" => ["beds"]},
      ...>  "$where" => %{"id" => 10}
      ...> }
      iex> fetch(FatEcto.FatHospital, query_opts)
      #Struct




  ## Options

    - `$find => $all`- To fetch all the results from database.
    - `$find => $one`- To fetch single record from database.
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$where`- Added the where attribute in the query.

  """

  def fetch(queryable, query_params) do
    query_params = FatEcto.FatHelper.map_deep_merge(@query_param_defaults, query_params)
    queryable = FatEcto.FatQuery.build(queryable, query_params)

    case query_params["$find"] do
      "$one" ->
        {:ok, @repo.one(Ecto.Query.limit(queryable, 1))}

      "$all" ->
        {:ok, paginate(queryable, skip: query_params["$skip"], limit: query_params["$limit"])}

      nil ->
        {:error, "Method not found"}

      _ ->
        {:error, "Method not found"}
    end
  end
end
