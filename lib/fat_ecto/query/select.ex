defmodule FatEcto.FatQuery.FatSelect do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      # TODO: Add docs and examples for ex_doc
      def build_select(queryable, opts_select, model) do
        case opts_select do
          nil ->
            queryable

          # TODO: Add docs and examples of ex_doc for this case here
          select when is_map(select) ->
            # TODO: Add docs and examples of ex_doc for this case here
            fields =
              Enum.reduce(select, [], fn {key, value}, fields ->
                if key == "$fields" do
                  fields ++ Enum.map(value, &String.to_existing_atom/1)
                else
                  # if map contain asso_table and fields
                  relation_name = String.to_existing_atom(key)
                  assoc_fields = value

                  FatEcto.FatHelper.associations(
                    model,
                    relation_name,
                    fields,
                    assoc_fields
                  )
                end
              end)

            from(q in queryable, select: map(q, ^Enum.uniq(fields)))

          select when is_list(select) ->
            from(q in queryable,
              select: map(q, ^Enum.uniq(Enum.map(select, &String.to_existing_atom/1)))
            )
        end
      end
    end
  end
end
