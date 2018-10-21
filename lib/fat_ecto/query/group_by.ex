defmodule FatEcto.FatQuery.FatGroupBy do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      # TODO: Add docs and examples for ex_doc
      def build_group_by(queryable, opts_group_by) do
        if opts_group_by == nil do
          queryable
        else
          queryable
          # TODO: build group by
        end
      end
    end
  end
end
