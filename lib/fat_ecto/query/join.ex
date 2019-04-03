defmodule FatEcto.FatQuery.FatJoin do
  # TODO: Add docs and examples for ex_doc
  alias FatEcto.FatHelper
  import Ecto.Query
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
      ...>      "$on_join_table_field" => "hospital_id",
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
    - `$on_join_table_field`- Specify the field for join in the joining table.


  """

  def build_join(queryable, join_params, join_type \\ "$join") do
    case join_params do
      nil ->
        queryable

      # TODO: Add docs and examples of ex_doc for this case here
      _join_params ->
        Enum.reduce(join_params, queryable, fn {join_key, join_item}, queryable ->
          join_table = join_item["$table"] || join_key

          join =
            String.replace(join_type, "_join", "")
            |> String.replace("$", "")
            |> FatHelper.string_to_atom()

          queryable =
            case join_item["$on_type"] do
              # TODO: Add docs and examples of ex_doc for this case here
              "$not_eq" ->
                queryable
                |> join(
                  join,
                  [q],
                  jt in ^join_table,
                  on:
                    field(q, ^FatHelper.string_to_atom(join_item["$on_field"])) !=
                      field(
                        jt,
                        ^FatHelper.string_to_atom(join_item["$on_join_table_field"])
                      )
                )

              "$gt" ->
                if FatHelper.is_fat_ecto_field?(join_item["$gt"]) do
                  queryable
                  |> join(
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
                  queryable
                  |> join(
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
                  queryable
                  |> join(
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
                  queryable
                  |> join(
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
                queryable
                |> join(
                  join,
                  [q],
                  jt in ^join_table,
                  on:
                    field(q, ^FatHelper.string_to_atom(join_item["$on_field"])) in field(
                      jt,
                      ^FatHelper.string_to_atom(join_item["$on_join_table_field"])
                    )
                )

              # TODO: Add docs and examples of ex_doc for this case here
              "$in" ->
                queryable
                |> join(
                  join,
                  [q],
                  jt in ^join_table,
                  on:
                    field(
                      jt,
                      ^FatHelper.string_to_atom(join_item["$on_join_table_field"])
                    ) in field(
                      q,
                      ^FatHelper.string_to_atom(join_item["$on_field"])
                    )
                )

              # TODO: Add docs and examples of ex_doc for this case here
              _whatever ->
                queryable
                |> join(
                  join,
                  [q],
                  jt in ^join_table,
                  on:
                    field(q, ^FatHelper.string_to_atom(join_item["$on_field"])) ==
                      field(
                        jt,
                        ^FatHelper.string_to_atom(join_item["$on_join_table_field"])
                      )
                )
            end

          # TODO: Add docs and examples of ex_doc for this case here
          queryable = FatEcto.FatQuery.FatWhere.build_where(queryable, join_item["$where"], binding: :last)

          queryable = order(queryable, join_item["$order"])
          _select(queryable, join_item, join_key)
        end)
    end
  end

  defp _select(queryable, join_params, join_table) do
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

        select_atoms = Enum.map(select, &FatHelper.string_to_atom/1)

        from(
          [q, ..., c] in queryable,
          select_merge: %{
            ^FatHelper.string_to_atom(join_table) => map(c, ^select_atoms)
          }
        )
    end
  end

  # TODO: Add docs and examples of ex_doc for this case here. try to use generic order
  defp order(queryable, order_by_params) do
    if order_by_params == nil do
      queryable
    else
      Enum.reduce(order_by_params, queryable, fn {field, format}, queryable ->
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
end
