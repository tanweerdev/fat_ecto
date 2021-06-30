defmodule FatEcto.IndexRecord do
  @moduledoc false
  @doc "Update a query before sending it in the fetch method. By default the query is name of your schema"
  @callback pre_process_fetch_query_for_index_method(query :: Ecto.Query.t(), conn :: Plug.Conn.t()) ::
              {:ok, Ecto.Query.t()}

  @doc "Perform any action after index"
  @callback after_fetch_hook_for_index_method(records :: list(), meta :: map(), conn :: Plug.Conn.t()) ::
              term()

  defmacro __using__(options \\ []) do
    quote location: :keep do
      alias FatEcto.MacrosHelper
      require Ecto.Query
      @behaviour FatEcto.IndexRecord

      @opt_app unquote(options)[:otp_app]
      @app_level_configs (@opt_app && Application.get_env(@opt_app, FatEcto.IndexRecord)) || []
      @unquoted_options unquote(options)
      @options Keyword.merge(@app_level_configs, @unquoted_options)

      @schema @options[:schema]
      @preloads @options[:preloads] || []
      @paginator_function @options[:paginator_function]
      @repo @options[:repo]

      if !@repo do
        raise "please define repo when using delete record"
      end

      if !@schema do
        raise "please define schema when using delete record"
      end

      def index(conn, params) do
        # TODO: below doesnt work so added condition for repo.all. Please fix preloads for paginator
        # query =
        #   if @preloads do
        #     Ecto.Query.preload(@schema, ^@preloads)
        #   else
        #     @schema
        #   end

        # TODO: add docs that paginator_function shoud return records and meta
        # eg {records, meta} = @paginator_function.(query, params)
        with {:ok, query} <- pre_process_fetch_query_for_index_method(@schema, conn) do
          _get_and_render(conn, query, params, @paginator_function, @repo)
        end
      end

      defp _get_and_render(conn, query, params, paginator_function, repo)
           when is_function(paginator_function, 3) do
        {records, meta} = paginator_function.(query, params, repo)
        after_fetch_hook_for_index_method(records, meta, conn)
        render_records(conn, records, meta, @options)
      end

      defp _get_and_render(conn, query, params, paginator_function, repo)
           when is_function(paginator_function, 2) do
        {records, meta} = paginator_function.(query, params)
        after_fetch_hook_for_index_method(records, meta, conn)
        render_records(conn, records, meta, @options)
      end

      defp _get_and_render(conn, query, params, paginator_function, repo)
           when not is_function(paginator_function) do
        records = repo.all(query)
        records = repo.preload(records, @preloads)
        after_fetch_hook_for_index_method(records, nil, conn)
        render_records(conn, records, nil, @options)
      end

      def pre_process_fetch_query_for_index_method(query, _conn) do
        {:ok, query}
      end

      def after_fetch_hook_for_index_method(_records, _meta, _conn) do
        "Override if needed"
      end

      defoverridable FatEcto.IndexRecord
    end
  end
end
