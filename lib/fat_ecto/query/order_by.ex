defmodule FatEcto.FatQuery.FatOrderBy do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      # TODO: Add docs and examples for ex_doc
      def build_order_by(queryable, opts_order_by) do
        if opts_order_by == nil do
          queryable
        else
          # TODO: Add docs and examples of ex_doc for this case here
          Enum.reduce(opts_order_by, queryable, fn {field, format}, queryable ->
            # TODO: Add docs and examples of ex_doc for this case here
            if format == "$desc" do
              from(
                queryable,
                order_by: [
                  desc: ^String.to_existing_atom(field)
                ]
              )
            else
              # TODO: Add docs and examples of ex_doc for this case here
              from(
                queryable,
                order_by: [
                  asc: ^String.to_existing_atom(field)
                ]
              )
            end
          end)
        end
      end
    end
  end
end
