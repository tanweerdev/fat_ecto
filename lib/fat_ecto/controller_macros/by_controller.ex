defmodule FatEcto.ByQuery do
  @moduledoc false

  defmacro __using__(options) do
    quote location: :keep do
      # quote do
      @repo unquote(options)[:repo]
      if !@repo do
        raise "please define repo when using by query"
      end

      @schema unquote(options)[:schema]
      @render_single_record_inside_object unquote(options)[:render_single_record_inside_object]

      if !@schema do
        raise "please define schema when using by query"
      end

      @paginator_function unquote(options)[:paginator_function]

      def query_by(conn, %{} = query_params) do
        # TODO: priority very low: if some query is invalid or due to any reason
        # there is some un-expected 500 or postgres error, it should be handled properly
        query_params = process_params_before_for_query_by(@schema, conn, query_params)
        queryable = process_query_before_for_query_by(@schema, conn, query_params)

        with {:ok, data_meta} <- FatEcto.Query.fetch(queryable, query_params) do
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

          after_get_hook_for_query_by(recordz, meta, conn)
          render_record_with_meta(conn, @schema, recordz, meta, unquote(options))
        end
      end

      def render_record_with_meta(conn, _schema, records, meta, options) do
        render_records(conn, records, meta, options)
      end

      # You can use process_query_before_for_query_by to override query before fetching records for query by
      def process_query_before_for_query_by(query, _conn, _params) do
        query
      end

      # You can use process_params_before_for_query_by to override query params before processing
      def process_params_before_for_query_by(_query, _conn, params) do
        params
      end

      # You can use after_get_hook_for_query_by to log etc
      def after_get_hook_for_query_by(_records, _meta, _conn) do
        "Override if needed"
      end

      defoverridable process_query_before_for_query_by: 3,
                     process_params_before_for_query_by: 3,
                     after_get_hook_for_query_by: 3,
                     render_record_with_meta: 5
    end
  end
end
