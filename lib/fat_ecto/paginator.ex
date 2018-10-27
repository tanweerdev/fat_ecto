defmodule FatEcto.FatPaginator do
  # TODO: make paginator optional via global config and via options passed
  # TODO: Add docs and examples for ex_doc
  defmacro __using__(options) do
    quote location: :keep do
      import Ecto.Query
      # TODO: @repo.all and @repo.one nil warning
      @repo unquote(options)[:repo]
      # TODO: Add docs and examples for ex_doc
      def paginate(query, params) do
        {skip, params} = FatEcto.FatHelper.get_skip_value(params)
        {limit, _params} = FatEcto.FatHelper.get_limit_value(params)

        %{
          data: data(query, skip, limit),
          meta: meta(query, skip, limit)
        }
      end

      defp meta(query, skip, limit) do
        %{
          skip: skip,
          limit: limit,
          count: count(query)
        }
      end

      defp data(query, skip, limit) do
        query
        |> limit([q], ^limit)
        |> offset([q], ^skip)
        |> @repo.all()
      end

      defp count(query) do
        queryable =
          query
          |> exclude(:order_by)
          |> exclude(:preload)
          |> exclude(:select)

        queryable =
          case FatEcto.FatHelper.field_exists?(queryable, :deleted_at) do
            false ->
              queryable

            true ->
              from(p in queryable, where: is_nil(p.deleted_at))
          end

        @repo.one(from(q in queryable, select: fragment("count(*)")))
      end
    end
  end
end
