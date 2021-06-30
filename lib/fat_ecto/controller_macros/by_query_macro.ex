defmodule FatEcto.ByQuery do
  @moduledoc false
  @doc "You can use pre_process_query_for_query_by_method to override query before fetching records for query by."
  @callback pre_process_query_for_query_by_method(
              query :: Ecto.Query.t(),
              conn :: Plug.Conn.t(),
              params :: map()
            ) ::
              {:ok, Ecto.Query.t()}
  @doc "You can use process_params_before_for_query_by to override query params before processing."
  @callback pre_process_params_for_query_by_method(
              query :: Ecto.Query.t(),
              conn :: Plug.Conn.t(),
              params :: map()
            ) :: {:ok, map()}
  @doc "You can use post_process_data_for_query_by_method to return custom records and meta"
  @callback post_process_data_for_query_by_method(
              recordz :: map() | list(),
              meta :: map() | nil,
              conn :: Plug.Conn.t()
            ) ::
              term()

  @doc "You can use post_fetch_hook_for_query_by_method to log etc."
  @callback post_fetch_hook_for_query_by_method(
              recordz :: map() | list(),
              meta :: map() | nil,
              conn :: Plug.Conn.t()
            ) ::
              term()
  @doc "You can use render_data_and_meta to make changes before records are sent to render macro."
  @callback render_data_and_meta(
              recordz :: map() | list(),
              meta :: map() | nil,
              conn :: Plug.Conn.t(),
              schema :: module(),
              options :: list()
            ) :: term()

  defmacro __using__(options \\ []) do
    quote location: :keep do
      @behaviour FatEcto.ByQuery
      @opt_app unquote(options)[:otp_app]
      @app_level_configs (@opt_app && Application.get_env(@opt_app, FatEcto.ByQuery)) || []
      @unquoted_options unquote(options)
      @options Keyword.merge(@app_level_configs, @unquoted_options)

      @repo @options[:repo]
      @query_module @options[:query_module]
      @schema @options[:schema]
      @render_single_record_inside_object @options[:render_single_record_inside_object]
      @paginator_function @options[:paginator_function]

      if !@opt_app do
        raise "please define opt app when using fat IQCRUD methods"
      end

      if !@repo do
        raise "please define repo when using by query"
      end

      if !@query_module do
        raise "please define query module when using by query"
      end

      if !@schema do
        raise "please define schema when using by query"
      end

      def query_by(conn, %{} = query_params) do
        # TODO: priority very low: if some query is invalid or due to any reason
        # there is some un-expected 500 or postgres error, it should be handled properly

        with {:ok, query_params} <- pre_process_params_for_query_by_method(@schema, conn, query_params),
             {:ok, queryable} <- pre_process_query_for_query_by_method(@schema, conn, query_params),
             {:ok, data_meta} <- @query_module.fetch(queryable, query_params) do
          {recordz, meta} =
            case data_meta do
              %{data: record, meta: nil, type: :object} ->
                count = if record == nil, do: 0, else: 1
                meta = %{limit: 1, count: count, offset: 0}

                if @render_single_record_inside_object do
                  {record, meta}
                else
                  {[record], meta}
                end

              %{data: records, meta: nil} ->
                # means pagination was false

                {records, nil}

              %{data: records, meta: meta} ->
                {records, meta}
            end

          {recordz, meta} = post_process_data_for_query_by_method(recordz, meta, conn)
          post_fetch_hook_for_query_by_method(recordz, meta, conn)
          render_data_and_meta(conn, @schema, recordz, meta, @options)
        end
      end

      def render_data_and_meta(conn, _schema, records, meta, options) do
        render_records(conn, records, meta, options)
      end

      # You can use pre_process_query_for_query_by_method to override query before fetching records for query by
      def pre_process_query_for_query_by_method(query, _conn, _params) do
        {:ok, query}
      end

      # You can use pre_process_params_for_query_by_method to override query params before processing
      def pre_process_params_for_query_by_method(_query, _conn, params) do
        {:ok, params}
      end

      # You can use post_process_data_for_query_by_method to return custom structs
      def post_process_data_for_query_by_method(records, meta, _conn) do
        {records, meta}
      end

      # You can use post_fetch_hook_for_query_by_method to log etc
      def post_fetch_hook_for_query_by_method(_records, _meta, _conn) do
        "Override if needed"
      end

      defoverridable FatEcto.ByQuery
    end
  end
end
