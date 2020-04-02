defmodule FatEcto.IndexRecord do
  @moduledoc false

  defmacro __using__(options) do
    quote do
      alias FatEcto.MacrosHelper
      require Ecto.Query

      @repo unquote(options)[:repo]
      if !@repo do
        raise "please define repo when using delete record"
      end

      @schema unquote(options)[:schema]
      if !@schema do
        raise "please define schema when using delete record"
      end

      @preloads unquote(options)[:preloads]
      @paginator_function unquote(options)[:paginator_function]

      def index(conn, params) do
        query =
          if @preloads do
            Ecto.Query.preload(@schema, ^@preloads)
          else
            @schema
          end

        # TODO: add docs that paginator_function shoud return records and meta
        # eg {records, meta} = @paginator_function.(query, params)
        cond do
          is_function(@paginator_function, 3) ->
            {records, meta} = @paginator_function.(query, params, @repo)
            render_records(conn, records, meta, unquote(options))

          is_function(@paginator_function, 2) ->
            {records, meta} = @paginator_function.(query, params)
            render_records(conn, records, meta, unquote(options))

          true ->
            records = @repo.all(query)
            render_records(conn, records, nil, unquote(options))
        end
      end
    end
  end
end
