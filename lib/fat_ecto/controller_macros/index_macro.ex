defmodule FatEcto.IndexRecord do
  @moduledoc false

  defmacro __using__(options) do
    # quote location: :keep do
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

        query = process_query_before_fetch_records_for_index(@schema, conn)
        # TODO: add docs that paginator_function shoud return records and meta
        # eg {records, meta} = @paginator_function.(query, params)
        _get_and_render(conn, query, params, @paginator_function, @repo)
      end

      defp _get_and_render(conn, query, params, paginator_function, repo)
           when is_function(paginator_function, 3) do
        {records, meta} = paginator_function.(query, params, repo)
        render_records(conn, records, meta, unquote(options))
      end

      defp _get_and_render(conn, query, params, paginator_function, repo)
           when is_function(paginator_function, 2) do
        {records, meta} = paginator_function.(query, params)
        render_records(conn, records, meta, unquote(options))
      end

      defp _get_and_render(conn, query, params, paginator_function, repo)
           when not is_function(paginator_function) do
        records = repo.all(query)
        render_records(conn, records, nil, unquote(options))
      end

      # You can use process_query_before_fetch_records_for_index to override query before fetching records for index
      def process_query_before_fetch_records_for_index(query, _conn) do
        query
      end

      defoverridable process_query_before_fetch_records_for_index: 2
    end
  end
end
