defmodule FatEcto.FatQuery.FatGroupBy do
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(_options) do
    quote location: :keep do
      alias FatEcto.FatHelper
      # TODO: Add docs and examples for ex_doc
      def build_group_by(queryable, opts_group_by) do
        if opts_group_by == nil do
          queryable
        else
          case opts_group_by do
            opts_group_by when is_list(opts_group_by) ->
              Enum.reduce(opts_group_by, queryable, fn group_by_field, queryable ->
                from(
                  q in queryable,
                  group_by: field(q, ^FatHelper.string_to_existing_atom(group_by_field))
                )
              end)

            opts_group_by when is_binary(opts_group_by) ->
              from(
                q in queryable,
                group_by: field(q, ^FatHelper.string_to_existing_atom(opts_group_by))
              )
          end
        end
      end
    end
  end
end
