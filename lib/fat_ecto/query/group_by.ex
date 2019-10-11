defmodule FatEcto.FatQuery.FatGroupBy do
  # TODO: Add docs and examples for ex_doc
  alias FatEcto.FatHelper
  import Ecto.Query
  # TODO: Add docs and examples for ex_doc

  @doc """
  Build a  `group_by query` depending on the params.
  ## Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map
  ## Examples
      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$order" => %{"id" => "$desc"},
      ...>  "$where" => %{"rating" => 4},
      ...>  "$group" => "total_staff"
      ...> }
      iex> #{FatEcto.FatQuery}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f in FatEcto.FatHospital, where: f.rating == ^4 and ^true, group_by: [f.total_staff], order_by: [desc: f.id], select: map(f, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}])>



  ## Options

    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$where`- Added the where attribute in the query.
    - `$group`- Added the group_by attribute in the query.
    - `$order`- Sort the result based on the order attribute.
  """
  def build_group_by(queryable, group_params, build_options, opts \\ [])

  def build_group_by(queryable, nil, _build_options, _opts) do
    queryable
  end

  def build_group_by(queryable, group_by_params, build_options, opts) do
    case group_by_params do
      group_by_params when is_list(group_by_params) ->
        Enum.reduce(group_by_params, queryable, fn group_by_field, queryable ->
          FatHelper.check_params_validity(build_options, queryable, group_by_field)

          _group_by(queryable, group_by_field, opts)
        end)

      group_by_params when is_map(group_by_params) ->
        Enum.reduce(group_by_params, queryable, fn {group_by_field, type}, queryable ->
          FatHelper.check_params_validity(build_options, queryable, group_by_field)

          case type do
            "$date_part_month" ->
              # from u in User,
              # group_by: fragment("date_part('month', ?)", u.inserted_at),
              # select:   {fragment("date_part('month', ?)", u.inserted_at), count(u.id)}
              field = FatHelper.string_to_existing_atom(group_by_field)

              if opts[:binding] do
                from(
                  [q, ..., c] in queryable,
                  group_by:
                    fragment(
                      "date_part('month', ?)",
                      field(c, ^field)
                    ),
                  select_merge: %{
                    "$group" => %{
                      ^group_by_field =>
                        fragment(
                          "date_part('month', ?)",
                          field(c, ^field)
                        )
                    }
                  }
                )
              else
                from(
                  q in queryable,
                  group_by:
                    fragment(
                      "date_part('month', ?)",
                      field(q, ^field)
                    ),
                  select_merge: %{
                    "$group" => %{
                      ^group_by_field =>
                        fragment(
                          "date_part('month', ?)",
                          field(q, ^field)
                        )
                    }
                  }
                )
              end

            "$date_part_year" ->
              # from u in User,
              # group_by: fragment("date_part('year', ?)", u.inserted_at),
              # select:   {fragment("date_part('year', ?)", u.inserted_at), count(u.id)}
              field = FatHelper.string_to_existing_atom(group_by_field)

              if opts[:binding] do
                from(
                  [q, ..., c] in queryable,
                  group_by:
                    fragment(
                      "date_part('year', ?)",
                      field(c, ^field)
                    ),
                  select_merge: %{
                    "$group" => %{
                      ^group_by_field =>
                        fragment(
                          "date_part('year', ?)",
                          field(c, ^field)
                        )
                    }
                  }
                )
              else
                from(
                  q in queryable,
                  group_by:
                    fragment(
                      "date_part('year', ?)",
                      field(q, ^field)
                    ),
                  select_merge: %{
                    "$group" => %{
                      ^group_by_field =>
                        fragment(
                          "date_part('year', ?)",
                          field(q, ^field)
                        )
                    }
                  }
                )
              end

            # "$date_part_month_count" ->
            #   # from u in User,
            #   # group_by: fragment("date_part('month', ?)", u.inserted_at),
            #   # select:   {fragment("date_part('month', ?)", u.inserted_at), count(u.id)}

            #   from(
            #     q in queryable,
            #     group_by:
            #       fragment(
            #         "date_part('month', ?)",
            #         field(q, ^FatHelper.string_to_existing_atom(group_by_field))
            #       ),
            #       select_merge: %{group_by_field => fragment(
            #         "date_part('month', ?)",
            #         field(q, ^FatHelper.string_to_existing_atom(group_by_field))
            #       ), count: fragment("count(*)")}
            #   )

            "$field" ->
              FatHelper.check_params_validity(build_options, queryable, group_by_field)

              _group_by(queryable, group_by_field, opts)
          end
        end)

      group_by_params when is_binary(group_by_params) ->
        FatHelper.check_params_validity(build_options, queryable, group_by_params)

        _group_by(queryable, group_by_params, opts)
    end
  end

  defp _group_by(queryable, group_by_param, opts) do
    field = FatHelper.string_to_existing_atom(group_by_param)

    if opts[:binding] do
      from(
        [q, ..., c] in queryable,
        group_by: field(c, ^field),
        select_merge: %{
          "$group" => %{
            ^group_by_param => field(c, ^field)
          }
        }
      )
    else
      from(
        q in queryable,
        group_by: field(q, ^field),
        select_merge: %{
          "$group" => %{
            ^group_by_param => field(q, ^field)
          }
        }
      )
    end
  end
end
