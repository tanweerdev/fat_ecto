defmodule FatEcto.FatQuery.FatMinimum do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      # TODO: Add docs and examples for ex_doc
      def build_minimum(queryable, opts_min) do
        Enum.reduce(opts_min, queryable, fn {k, v}, queryable ->
          case v do
            nil ->
              queryable

            # TODO: Add docs and examples of ex_doc for this case here
            v when is_list(v) ->
              value = Enum.at(v, 0)

              from(
                q in queryable,
                order_by: [
                  asc: ^String.to_existing_atom(value)
                ],
                limit: 1
              )
          end
        end)
      end
    end
  end
end
