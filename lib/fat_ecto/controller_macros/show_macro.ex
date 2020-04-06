defmodule FatEcto.ShowRecord do
  @moduledoc false

  defmacro __using__(options) do
    # quote location: :keep do
    quote do
      alias FatEcto.MacrosHelper

      @repo unquote(options)[:repo]
      if !@repo do
        raise "please define repo when using delete record"
      end

      @schema unquote(options)[:schema]
      if !@schema do
        raise "please define schema when using delete record"
      end

      @preloads unquote(options)[:preloads] || []

      def show(conn, %{"id" => id}) do
        query = process_query_before_fetch_record_for_show(@schema, conn)

        case MacrosHelper.get_record_by_query(:id, id, @repo, query) do
          {:error, :not_found} ->
            error_view_module = unquote(options)[:error_view_module]
            error_view = unquote(options)[:error_view_404]
            data_to_view_as = unquote(options)[:error_data_to_view_as]

            render_record(
              conn,
              "Record not found",
              unquote(options) ++
                [
                  status_to_put: 404,
                  put_view_module: error_view_module,
                  view_to_render: error_view,
                  data_to_view_as: data_to_view_as
                ]
            )

          {:ok, record} ->
            record = MacrosHelper.preload_record(record, @repo, @preloads)
            after_get_hook_for_show(record, conn)
            render_record(conn, record, unquote(options) ++ [status_to_put: :ok])
        end
      end

      # You can use process_query_before_fetch_record_for_show to override query before fetching record for show
      def process_query_before_fetch_record_for_show(query, _conn) do
        query
      end

      # You can use after_get_hook_for_show to log etc
      def after_get_hook_for_show(_record, _conn) do
        "Override if needed"
      end

      defoverridable process_query_before_fetch_record_for_show: 2, after_get_hook_for_show: 2
    end
  end
end
