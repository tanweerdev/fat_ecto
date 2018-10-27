defmodule FatEcto.FatQuery.FatInclude do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      # TODO: Add docs and examples for ex_doc
      def build_include(queryable, opts_include, model) do
        case opts_include do
          nil ->
            queryable

          # TODO: Add docs and examples for ex_doc
          include when is_map(include) ->
            Enum.reduce(include, queryable, fn {key, value}, queryable ->
              relation_name = String.to_existing_atom(key)

              %{owner: _o, owner_key: _ok, related: related_model, related_key: _rk} =
                FatEcto.FatHelper.model_related_owner(model, relation_name)

              include_kwery =
                related_model
                |> FatEcto.FatQuery.build_select(value["$select"], related_model)
                |> FatEcto.FatQuery.build_where(value["$where"], binding: :last)
                |> FatEcto.FatQuery.build_order_by(value["$order"])
                |> FatEcto.FatQuery.build_include(value["$include"], related_model)
                |> limit([q], ^FatEcto.FatHelper.get_limit(value["$limit"]))
                |> offset([q], ^(value["$offset"] || 0))

              join = String.replace(value["$join"] || "$inner", "$", "") |> String.to_atom()

              queryable
              |> join(join, [q], jn in assoc(q, ^relation_name))
              |> preload([q, ..., jt], [{^relation_name, ^include_kwery}])
            end)

          # TODO: Add docs and examples of ex_doc for this case here
          include when is_binary(include) ->
            from(
              q in queryable,
              left_join: a in assoc(q, ^String.to_existing_atom(include)),
              preload: [^String.to_existing_atom(include)]
            )

          # TODO: Add docs and examples of ex_doc for this case here
          include when is_list(include) ->
            # TODO: implement logic for the
            Enum.reduce(include, queryable, fn model, queryable ->
              # case model do
              # TODO: include: [{hospital: {$fields: [], $where: {}}}, {rooms: {$fields: [], $where: {}}}]
              #   m when is_map(m) ->
              #     queryable

              #   m when is_binary(m) ->
              from(
                q in queryable,
                left_join: a in assoc(q, ^String.to_existing_atom(model)),
                preload: [^String.to_existing_atom(model)]
              )

              # end
            end)
        end
      end
    end
  end
end
