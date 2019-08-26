defmodule FatEcto.FatQuery.FatJoin do
  # TODO: Add docs and examples for ex_doc
  alias FatEcto.FatHelper
  import Ecto.Query
  alias FatEcto.FatQuery.{FatDynamics, FatNotDynamics}

  # TODO: Add docs and examples for ex_doc

  @doc """
  Build a  `join query` depending on the params.
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
      ...>  "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"name" => "ham"},
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
      iex> #{FatEcto.FatQuery}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, right_join: f1 in "fat_rooms", on: f0.id == f1.hospital_id, join: f2 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, where: f1.incharge == ^"John" and ^true, order_by: [desc: f0.id], select: merge(map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), %{^:fat_rooms => map(f1, [:beds, :capacity, :level])}), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.name == ^"ham" and ^true, order_by: [desc: f.id], limit: ^10, offset: ^0, preload: [:fat_patients]>]>





  ## Options

    - `$include`- Include the assoication `doctors`.
    - `$include: :fat_patients`- Include the assoication `patients`. Which has association with `doctors`.
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$where`- Added the where attribute in the query.
    - `$order`- Sort the result based on the order attribute.
    - `$right_join`- Specify the type of join.
    - `$on_field`- Specify the field for join.
    - `$on_table_field`- Specify the field for join in the joining table.


  """

  def build_join(queryable, join_params, join_type \\ "$join", options)

  def build_join(queryable, nil, _join_type, _options) do
    queryable
  end

  def build_join(queryable, join_params, join_type, options) do
    # TODO: Add docs and examples of ex_doc for this case here
    Enum.reduce(join_params, queryable, fn {join_key, join_item}, queryable ->
      join_table = join_item["$on_table"] || join_key

      join =
        join_type
        |> String.replace("_join", "")
        |> String.replace("$", "")
        |> FatHelper.string_to_atom()

      FatHelper.params_valid(queryable, join_item["$on_field"], options[:otp_app])
      FatHelper.params_valid(join_table, join_item["$on_table_field"], options[:otp_app])

      queryable =
        case join_item["$on_type"] do
          # TODO: Add docs and examples of ex_doc for this case here
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

          # TODO: Add docs and examples of ex_doc for this case here
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

          # TODO: Add docs and examples of ex_doc for this case here
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

          # TODO: Add docs and examples of ex_doc for this case here
          _whatever ->
            on_caluses =
              build_on_dynamic(join_table, join_item, join_item["$additional_on_clauses"], options[:otp_app])

            join(
              queryable,
              join,
              [q],
              jt in ^join_table,
              on: ^on_caluses
            )
        end

      # TODO: Add docs and examples of ex_doc for this case here
      queryable =
        FatEcto.FatQuery.FatWhere.build_where(queryable, join_item["$where"], options, binding: :last)

      queryable = order(queryable, join_item["$order"], options[:otp_app])
      queryable = _select(queryable, join_item, join_key, options[:otp_app])
      build_group_by(queryable, join_item["$group"], options[:otp_app])
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
        select = FatHelper.params_valid(queryable, select, app)

        select_atoms = Enum.map(select, &FatHelper.string_to_atom/1)

        from(
          [q, ..., c] in queryable,
          select_merge: %{
            ^join_table => map(c, ^select_atoms)
          }
        )
    end
  end

  # TODO: Add docs and examples of ex_doc for this case here. try to use generic order
  defp order(queryable, order_by_params, app) do
    if order_by_params == nil do
      queryable
    else
      Enum.reduce(order_by_params, queryable, fn {field, format}, queryable ->
        field = FatHelper.params_valid(queryable, field, app)

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

  defp build_group_by(queryable, nil, _app) do
    queryable
  end

  defp build_group_by(queryable, group_by_params, app) do
    case group_by_params do
      group_by_params when is_list(group_by_params) ->
        Enum.reduce(group_by_params, queryable, fn group_by_field, queryable ->
          group_by_field = FatHelper.params_valid(queryable, group_by_field, app)

          _group_by(queryable, group_by_field)
        end)

      group_by_params when is_map(group_by_params) ->
        Enum.reduce(group_by_params, queryable, fn {group_by_field, type}, queryable ->
          group_by_field = FatHelper.params_valid(queryable, group_by_field, app)

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
              group_by_field = FatHelper.params_valid(queryable, group_by_field, app)

              _group_by(queryable, group_by_field)
          end
        end)

      group_by_params when is_binary(group_by_params) ->
        group_by_field = FatHelper.params_valid(queryable, group_by_params, app)

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

  def build_on_dynamic(_join_table, join_items, nil, app) do
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

  def build_on_dynamic(join_table, join_items, additional_join, app) do
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

  def build_on_dynamic(join_table, _join_items, {field, map}, dynamics, binding, app) do
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
end
