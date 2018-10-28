defmodule FatEcto.FatQuery.FatJoin do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      alias FatEcto.FatHelper
      # TODO: Add docs and examples for ex_doc
      def build_join(queryable, opts, join_type \\ "$join") do
        case opts do
          nil ->
            queryable

          # TODO: Add docs and examples of ex_doc for this case here
          _opts ->
            Enum.reduce(opts, queryable, fn {join_key, join_opts}, queryable ->
              join_table = join_opts["$table"] || join_key

              join =
                String.replace(join_type, "_join", "")
                |> String.replace("$", "")
                |> FatHelper.string_to_atom()

              queryable =
                case join_opts["$on_type"] do
                  # TODO: Add docs and examples of ex_doc for this case here
                  "$not_eq" ->
                    queryable
                    |> join(
                      join,
                      [q],
                      jt in ^join_table,
                      field(q, ^FatHelper.string_to_atom(join_opts["$on_field"])) !=
                        field(
                          jt,
                          ^FatHelper.string_to_atom(join_opts["$on_join_table_field"])
                        )
                    )

                  # TODO: Add docs and examples of ex_doc for this case here
                  "$in_x" ->
                    queryable
                    |> join(
                      join,
                      [q],
                      jt in ^join_table,
                      field(q, ^FatHelper.string_to_atom(join_opts["$on_field"])) in field(
                        jt,
                        ^FatHelper.string_to_atom(join_opts["$on_join_table_field"])
                      )
                    )

                  # TODO: Add docs and examples of ex_doc for this case here
                  "$in" ->
                    queryable
                    |> join(
                      join,
                      [q],
                      jt in ^join_table,
                      field(
                        jt,
                        ^FatHelper.string_to_atom(join_opts["$on_join_table_field"])
                      ) in field(
                        q,
                        ^FatHelper.string_to_atom(join_opts["$on_field"])
                      )
                    )

                  # TODO: Add docs and examples of ex_doc for this case here
                  _whatever ->
                    queryable
                    |> join(
                      join,
                      [q],
                      jt in ^join_table,
                      field(q, ^FatHelper.string_to_atom(join_opts["$on_field"])) ==
                        field(
                          jt,
                          ^FatHelper.string_to_atom(join_opts["$on_join_table_field"])
                        )
                    )
                end

              queryable =
                if join_opts["$where"] == nil do
                  queryable
                else
                  # TODO: Add docs and examples of ex_doc for this case here
                  FatEcto.FatQuery.build_where(queryable, join_opts["$where"], binding: :last)
                end

              queryable = order(queryable, join_opts["$order"])
              queryable = _select(queryable, join_opts, join_key)
            end)
        end
      end

      defp _select(queryable, join_opts, join_table) do
        case join_opts["$select"] do
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

            from([q, ..., c] in queryable,
              select_merge: %{
                ^FatHelper.string_to_atom(join_table) => map(c, ^select_atoms)
              }
            )
        end
      end

      # TODO: Add docs and examples of ex_doc for this case here. try to use generic order
      defp order(queryable, opts_order_by) do
        if opts_order_by == nil do
          queryable
        else
          Enum.reduce(opts_order_by, queryable, fn {field, format}, queryable ->
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
  end
end
