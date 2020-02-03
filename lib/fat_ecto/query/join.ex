defmodule FatEcto.FatQuery.FatJoin do
  alias FatEcto.FatHelper
  import Ecto.Query
  alias FatEcto.FatQuery.{FatDynamics, FatNotDynamics}

  @moduledoc """
  Builds a `join` query with another table on the type of join passed in the params. It also supports additional `join_on` clauses.
  ### $right_join
  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Join query options as a map

  ### Examples

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$order" => %{"id" => "$desc"},
      ...>  "$where" => %{"rating" => 4},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"experience_years" => 2},
      ...>      "$order" => %{"id" => "$desc"}
      ...>    }
      ...>  },
      ...>  "$right_join" => %{
      ...>    "fat_rooms" => %{
      ...>      "$on_field" => "id",
      ...>      "$on_table_field" => "hospital_id",
      ...>      "$on_type" => "$in_x",
      ...>      "$select" => ["beds", "capacity", "level"],
      ...>      "$where" => %{"incharge" => "John"}
      ...>    }
      ...>  }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id in f1.hospital_id, left_join: f2 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, where: f1.incharge == ^"John" and ^true, where: f2.experience_years == ^2 and ^true, order_by: [desc: f2.id], order_by: [desc: f0.id], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, {:fat_rooms, [:beds, :capacity]}]), %{^"fat_rooms" => map(f1, [:beds, :capacity, :level])}), preload: [[fat_doctors: [:fat_patients]]]>

  ## Options

    - `$include`               - Include the assoication `doctors`.
    - `$include: :fat_patients`- Include the assoication `patients`. Which has association with `doctors`.
    - `$select`                - Select the fields from `hospital` and `rooms`.
    - `$where`                 - Added the where attribute in the query.
    - `$order`                 - Sort the result based on the order attribute.
    - `$right_join`            - Specify the type of join.  
    - `$on_type`               -  Specify the type of condition on the join.
    - `$on_field`              - Specify the field for join.
    - `$on_table_field`        - Specify the field for join in the joining table.

  ### $left_join
  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Join query options as a map

  ### Examples

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$order" => %{"id" => "$desc"},
      ...>  "$where" => %{"rating" => 4},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"experience_years" => 2},
      ...>      "$order" => %{"id" => "$desc"}
      ...>    }
      ...>  },
      ...>  "$left_join" => %{
      ...>    "fat_rooms" => %{
      ...>      "$on_field" => "id",
      ...>      "$on_table_field" => "hospital_id",
      ...>      "$on_type" => "$not_eq",
      ...>      "$select" => ["beds", "capacity", "level"],
      ...>      "$where" => %{"incharge" => "John"}
      ...>    }
      ...>  }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, left_join: f1 in "fat_rooms", on: f0.id != f1.hospital_id, left_join: f2 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, where: f1.incharge == ^"John" and ^true, where: f2.experience_years == ^2 and ^true, order_by: [desc: f2.id], order_by: [desc: f0.id], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, {:fat_rooms, [:beds, :capacity]}]), %{^"fat_rooms" => map(f1, [:beds, :capacity, :level])}), preload: [[fat_doctors: [:fat_patients]]]>

  ## Options

    - `$include`               - Include the assoication `doctors`.
    - `$include: :fat_patients`- Include the assoication `patients`. Which has association with `doctors`.
    - `$select`                - Select the fields from `hospital` and `rooms`.
    - `$where`                 - Added the where attribute in the query.
    - `$order`                 - Sort the result based on the order attribute.
    - `$right_join`            - Specify the type of join.
    - `$on_type`               -  Specify the type of condition on the join.
    - `$on_field`              - Specify the field for join.
    - `$on_table_field`        - Specify the field for join in the joining table.

  ### $inner_join
  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Join query options as a map

  ### Examples

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$order" => %{"id" => "$desc"},
      ...>  "$where" => %{"rating" => 4},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"experience_years" => 2},
      ...>      "$order" => %{"id" => "$desc"}
      ...>    }
      ...>  },
      ...>  "$inner_join" => %{
      ...>    "fat_rooms" => %{
      ...>      "$on_field" => "id",
      ...>      "$on_table_field" => "hospital_id",
      ...>      "$on_type" => "$in",
      ...>      "$select" => ["beds", "capacity", "level"],
      ...>      "$where" => %{"incharge" => "John"}
      ...>    }
      ...>  }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in "fat_rooms", on: f1.hospital_id in f0.id, left_join: f2 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, where: f1.incharge == ^"John" and ^true, where: f2.experience_years == ^2 and ^true, order_by: [desc: f2.id], order_by: [desc: f0.id], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, {:fat_rooms, [:beds, :capacity]}]), %{^"fat_rooms" => map(f1, [:beds, :capacity, :level])}), preload: [[fat_doctors: [:fat_patients]]]>

  ## Options

    - `$include`               - Include the assoication `doctors`.
    - `$include: :fat_patients`- Include the assoication `patients`. Which has association with `doctors`.
    - `$select`                - Select the fields from `hospital` and `rooms`.
    - `$where`                 - Added the where attribute in the query.
    - `$order`                 - Sort the result based on the order attribute.
    - `$right_join`            - Specify the type of join.
    - `$on_type`               -  Specify the type of condition on the join.
    - `$on_field`              - Specify the field for join.
    - `$on_table_field`        - Specify the field for join in the joining table.

  ### $full_join
  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Join query options as a map

  ### Examples

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$order" => %{"id" => "$desc"},
      ...>  "$where" => %{"rating" => 4},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"experience_years" => 2},
      ...>      "$order" => %{"id" => "$desc"}
      ...>    }
      ...>  },
      ...>  "$full_join" => %{
      ...>    "fat_rooms" => %{
      ...>      "$on_field" => "id",
      ...>      "$on_table_field" => "hospital_id",
      ...>      "$select" => ["beds", "capacity", "level"],
      ...>      "$where" => %{"incharge" => "John"}
      ...>    }
      ...>  }
      ...> }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, full_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, left_join: f2 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, where: f1.incharge == ^"John" and ^true, where: f2.experience_years == ^2 and ^true, order_by: [desc: f2.id], order_by: [desc: f0.id], limit: ^34, offset: ^0, select: merge(map(f0, [:name, :location, :rating, {:fat_rooms, [:beds, :capacity]}]), %{^"fat_rooms" => map(f1, [:beds, :capacity, :level])}), preload: [[fat_doctors: [:fat_patients]]]>


  ## Options

    - `$include`               - Include the assoication `doctors`.
    - `$include: :fat_patients`- Include the assoication `patients`. Which has association with `doctors`.
    - `$select`                - Select the fields from `hospital` and `rooms`.
    - `$where`                 - Added the where attribute in the query.
    - `$order`                 - Sort the result based on the order attribute.
    - `$right_join`            - Specify the type of join.
    - `$on_field`              - Specify the field for join.
    - `$on_table_field`        - Specify the field for join in the joining table.

  """

  def build_join(queryable, join_params, join_type \\ "$join", options)

  def build_join(queryable, nil, _join_type, _options) do
    queryable
  end

  @doc """
   Builds a join query based on the join type passed in the params.


  ### Parameters

  - `queryable`   -  Ecto Queryable that represents your schema name, table name or query.
  - `join_params` -  Join query options as a map.
  - `join_type`   -  Type of join.
  - `options`     -  Pass options related to otp_app.


  ### Examples

      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$order" => %{"id" => "$desc"},
      ...>  "$where" => %{"rating" => 4},
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"experience_years" => 2},
      ...>      "$order" => %{"id" => "$desc"}
      ...>    }
      ...>  },
      ...>  "$right_join" => %{
      ...>    "fat_rooms" => %{
      ...>      "$on_field" => "id",
      ...>      "$on_table_field" => "hospital_id",
      ...>      "$select" => ["beds", "capacity", "level"],
      ...>      "$where" => %{"incharge" => "John"}
      ...>    }
      ...>  }
      ...> }
      iex> #{__MODULE__}.build_join(FatEcto.FatHospital, query_opts["$right_join"], "$right_join", [])
      #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, where: f1.incharge == ^"John" and ^true, select: %{^"fat_rooms" => map(f1, [:beds, :capacity, :level])}>
  """

  def build_join(queryable, join_params, join_type, options) do
    Enum.reduce(join_params, queryable, fn {join_key, join_item}, queryable ->
      join_table = join_item["$on_table"] || join_key

      join =
        join_type
        |> String.replace("_join", "")
        |> String.replace("$", "")
        |> FatHelper.string_to_atom()

      FatHelper.params_valid(queryable, join_item["$on_field"], options)
      FatHelper.params_valid(join_table, join_item["$on_table_field"], options)

      queryable =
        case join_item["$on_type"] do
          "$not_eq" ->
            join(
              queryable,
              join,
              [q],
              jt in ^join_table,
              on:
                field(q, ^FatHelper.string_to_atom(join_item["$on_field"])) !=
                  field(
                    jt,
                    ^FatHelper.string_to_atom(join_item["$on_table_field"])
                  )
            )

          "$gt" ->
            if FatHelper.is_fat_ecto_field?(join_item["$gt"]) do
              join(
                queryable,
                join,
                [q],
                jt in ^join_table,
                on:
                  field(q, ^FatHelper.string_to_atom(join_item["$on_field"])) >
                    field(
                      jt,
                      ^FatHelper.string_to_atom(join_item["$gt"])
                    )
              )
            else
              join(
                queryable,
                join,
                [q],
                jt in ^join_table,
                on:
                  field(q, ^FatHelper.string_to_atom(join_item["$on_field"])) >
                    field(
                      jt,
                      ^FatHelper.string_to_atom(join_item["$gt"])
                    )
              )
            end

          "$lt" ->
            if FatHelper.is_fat_ecto_field?(join_item["$gt"]) do
              join(
                queryable,
                join,
                [q],
                jt in ^join_table,
                on:
                  field(q, ^FatHelper.string_to_atom(join_item["$on_field"])) <
                    field(
                      jt,
                      ^FatHelper.string_to_atom(join_item["$gt"])
                    )
              )
            else
              join(
                queryable,
                join,
                [q],
                jt in ^join_table,
                on:
                  field(q, ^FatHelper.string_to_atom(join_item["$on_field"])) <
                    field(
                      jt,
                      ^FatHelper.string_to_atom(join_item["$gt"])
                    )
              )
            end

          "$in_x" ->
            join(
              queryable,
              join,
              [q],
              jt in ^join_table,
              on:
                field(q, ^FatHelper.string_to_atom(join_item["$on_field"])) in field(
                  jt,
                  ^FatHelper.string_to_atom(join_item["$on_table_field"])
                )
            )

          "$in" ->
            join(
              queryable,
              join,
              [q],
              jt in ^join_table,
              on:
                field(
                  jt,
                  ^FatHelper.string_to_atom(join_item["$on_table_field"])
                ) in field(
                  q,
                  ^FatHelper.string_to_atom(join_item["$on_field"])
                )
            )

          _whatever ->
            on_caluses = build_on_dynamic(join_table, join_item, join_item["$additional_on_clauses"], options)

            join(
              queryable,
              join,
              [q],
              jt in ^join_table,
              on: ^on_caluses
            )
        end

      queryable =
        FatEcto.FatQuery.FatWhere.build_where(queryable, join_item["$where"], options ++ [table: join_table],
          binding: :last
        )

      queryable = order(queryable, join_item["$order"], join_table, options)
      queryable = _select(queryable, join_item, join_table, options)
      build_group_by(queryable, join_item["$group"], join_table, options)
    end)
  end

  defp _select(queryable, join_params, join_table, app) do
    case join_params["$select"] do
      nil ->
        queryable

      # TODO: Add docs and examples of ex_doc for this case here
      # keep in mind, this is part of join, so example should be with join select
      select when is_list(select) ->
        # Below syntax doesn't support ... in binding
        # queryable |> select_merge([q, c], (%{location_dest_zone: map(c, ^select_atoms)}))

        # TODO: use dynamics to build queries whereever possible
        # dynamic = dynamic([q, ..., c], c.id == 1)
        # from query, where: ^dynamic
        FatHelper.params_valid(join_table, select, app)

        select_atoms = Enum.map(select, &FatHelper.string_to_atom/1)

        queryable = select_exists(queryable)

        from(
          [q, ..., c] in queryable,
          select_merge: %{
            ^join_table => map(c, ^select_atoms)
          }
        )
    end
  end

  # TODO: Add docs and examples of ex_doc for this case here. try to use generic order
  defp order(queryable, order_by_params, join_table, app) do
    if order_by_params == nil do
      queryable
    else
      Enum.reduce(order_by_params, queryable, fn {field, format}, queryable ->
        FatHelper.params_valid(join_table, field, app)

        if format == "$desc" do
          from(
            [q, ..., c] in queryable,
            order_by: [
              desc: field(c, ^FatHelper.string_to_existing_atom(field))
            ]
          )
        else
          from(
            [q, ..., c] in queryable,
            order_by: [
              asc: field(c, ^FatHelper.string_to_existing_atom(field))
            ]
          )
        end
      end)
    end
  end

  defp build_group_by(queryable, nil, _join_table, _app) do
    queryable
  end

  defp build_group_by(queryable, group_by_params, join_table, app) do
    case group_by_params do
      group_by_params when is_list(group_by_params) ->
        Enum.reduce(group_by_params, queryable, fn group_by_field, queryable ->
          FatHelper.params_valid(join_table, group_by_field, app)

          _group_by(queryable, group_by_field)
        end)

      group_by_params when is_map(group_by_params) ->
        Enum.reduce(group_by_params, queryable, fn {group_by_field, type}, queryable ->
          FatHelper.params_valid(join_table, group_by_field, app)

          case type do
            "$date_part_month" ->
              # from u in User,
              # group_by: fragment("date_part('month', ?)", u.inserted_at),
              # select:   {fragment("date_part('month', ?)", u.inserted_at), count(u.id)}
              field = FatHelper.string_to_existing_atom(group_by_field)

              from(
                [first, ..., q] in queryable,
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

            "$date_part_year" ->
              # from u in User,
              # group_by: fragment("date_part('year', ?)", u.inserted_at),
              # select:   {fragment("date_part('year', ?)", u.inserted_at), count(u.id)}
              field = FatHelper.string_to_existing_atom(group_by_field)

              from(
                [first, ..., q] in queryable,
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

            "$field" ->
              FatHelper.params_valid(join_table, group_by_field, app)

              _group_by(queryable, group_by_field)
          end
        end)

      group_by_params when is_binary(group_by_params) ->
        FatHelper.params_valid(join_table, group_by_params, app)

        _group_by(queryable, group_by_params)
    end
  end

  defp _group_by(queryable, group_by_param) do
    field = FatHelper.string_to_existing_atom(group_by_param)

    from(
      [first, ..., q] in queryable,
      group_by: field(q, ^field),
      select_merge: %{
        "$group" => %{
          ^group_by_param => field(q, ^field)
        }
      }
    )
  end

  defp build_on_dynamic(_join_table, join_items, nil, _app) do
    dynamic(
      [q, ..., c],
      field(
        q,
        ^FatHelper.string_to_atom(join_items["$on_field"])
      ) ==
        field(
          c,
          ^FatHelper.string_to_atom(join_items["$on_table_field"])
        )
    )
  end

  defp build_on_dynamic(join_table, join_items, additional_join, app) do
    dynamics =
      Enum.reduce(additional_join, true, fn {field, map}, dynamics ->
        {binding, map} = Map.pop(map, "$binding")
        build_on_dynamic(join_table, join_items, {field, map}, dynamics, binding, app)
      end)

    dynamic(
      [q, ..., c],
      field(
        q,
        ^FatHelper.string_to_atom(join_items["$on_field"])
      ) ==
        field(
          c,
          ^FatHelper.string_to_atom(join_items["$on_table_field"])
        ) and ^dynamics
    )
  end

  defp build_on_dynamic(join_table, _join_items, {field, map}, dynamics, binding, app) do
    FatHelper.params_valid(join_table, field, app)

    Enum.reduce(map, [], fn {k, value}, opts ->
      case k do
        "$in" ->
          FatDynamics.in_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])

        "$between_equal" ->
          if binding do
            FatDynamics.between_equal_dynamic(
              field,
              value,
              dynamics,
              opts ++ [dynamic_type: :and, binding: :last]
            )
          else
            FatDynamics.between_equal_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$between" ->
          if binding do
            FatDynamics.between_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and, binding: :last])
          else
            FatDynamics.between_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$gt" ->
          if binding do
            FatDynamics.gt_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and, binding: :last])
          else
            FatDynamics.gt_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$gte" ->
          if binding do
            FatDynamics.gte_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and, binding: :last])
          else
            FatDynamics.gte_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$lt" ->
          if binding do
            FatDynamics.lt_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and, binding: :last])
          else
            FatDynamics.lt_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$lte" ->
          if binding do
            FatDynamics.lte_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and, binding: :last])
          else
            FatDynamics.lte_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$like" ->
          if binding do
            FatDynamics.like_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and, binding: :last])
          else
            FatDynamics.like_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$ilike" ->
          if binding do
            FatDynamics.ilike_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and, binding: :last])
          else
            FatDynamics.ilike_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$not_like" ->
          if binding do
            FatNotDynamics.not_like_dynamic(
              field,
              value,
              dynamics,
              opts ++ [dynamic_type: :and, binding: :last]
            )
          else
            FatNotDynamics.not_like_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$not_ilike" ->
          if binding do
            FatNotDynamics.not_ilike_dynamic(
              field,
              value,
              dynamics,
              opts ++ [dynamic_type: :and, binding: :last]
            )
          else
            FatNotDynamics.not_ilike_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$not_between" ->
          if binding do
            FatNotDynamics.not_between_dynamic(
              field,
              value,
              dynamics,
              opts ++ [dynamic_type: :and, binding: :last]
            )
          else
            FatNotDynamics.not_between_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$not_between_equal" ->
          if binding do
            FatNotDynamics.not_between_equal_dynamic(
              field,
              value,
              dynamics,
              opts ++ [dynamic_type: :and, binding: :last]
            )
          else
            FatNotDynamics.not_between_equal_dynamic(
              field,
              value,
              dynamics,
              opts ++ [dynamic_type: :and]
            )
          end

        "$not_in" ->
          if binding do
            FatNotDynamics.not_in_dynamic(
              field,
              value,
              dynamics,
              opts ++ [dynamic_type: :and, binding: :last]
            )
          else
            FatNotDynamics.not_in_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        "$equal" ->
          if binding do
            FatDynamics.eq_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and, binding: :last])
          else
            FatDynamics.eq_dynamic(field, value, dynamics, opts ++ [dynamic_type: :and])
          end

        _ ->
          dynamics
      end
    end)
  end

  defp select_exists(%{select: nil} = queryable) do
    from([q, ..., c] in queryable, select: %{})
  end

  defp select_exists(queryable), do: queryable
end
