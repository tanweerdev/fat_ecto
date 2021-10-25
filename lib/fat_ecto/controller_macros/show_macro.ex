defmodule FatEcto.ShowRecord do
  @moduledoc false

  @doc "Update a query before sending it in the fetch method. By default the query is name of your schema"
  @callback pre_process_fetch_query_for_show_method(query :: Ecto.Query.t(), conn :: Plug.Conn.t()) ::
              {:ok, Ecto.Query.t()}

  @doc "Perform any action after show"
  @callback post_fetch_hook_for_show_method(record :: struct(), conn :: Plug.Conn.t()) :: term()

  defmacro __using__(options \\ []) do
    quote location: :keep do
      alias FatEcto.MacrosHelper
      @behaviour FatEcto.ShowRecord

      @opt_app unquote(options)[:otp_app]
      @app_level_configs (@opt_app && Application.get_env(@opt_app, FatEcto.ShowRecord)) || []
      @unquoted_options unquote(options)
      @options Keyword.merge(@app_level_configs, @unquoted_options)

      @repo @options[:repo][:module]
      if !@repo do
        raise "please define repo when using delete record"
      end

      @schema @options[:schema][:module]
      if !@schema do
        raise "please define schema when using delete record"
      end

      @preloads @options[:preloads] || []

      @get_by_unqiue_field @options[:get_by_unqiue_field]

      if @get_by_unqiue_field in [nil, ""] do
        def show(conn, %{"id" => id}) do
          _show(conn, %{"key" => :id, "value" => id})
        end
      else
        def show(conn, %{@get_by_unqiue_field => value}) do
          _show(conn, %{"key" => @get_by_unqiue_field, "value" => value})
        end
      end

      defp _show(conn, %{"key" => key, "value" => value}) do
        with {:ok, query} <- pre_process_fetch_query_for_show_method(@schema, conn) do
          case MacrosHelper.get_record_by_query(key, value, @repo, query) do
            {:error, :not_found} ->
              error_view_module = @options[:error_view_module]
              error_view = @options[:error_view_404]
              data_to_view_as = @options[:error_data_to_view_as]

              render_record(
                conn,
                "Record not found",
                [
                  status_to_put: 404,
                  put_view_module: error_view_module,
                  view_to_render: error_view,
                  data_to_view_as: data_to_view_as
                ] ++ @options
              )

            {:ok, record} ->
              record = MacrosHelper.preload_record(record, @repo, @preloads)
              post_fetch_hook_for_show_method(record, conn)
              render_record(conn, record, [status_to_put: :ok] ++ @options)
          end
        end
      end

      def pre_process_fetch_query_for_show_method(query, _conn) do
        {:ok, query}
      end

      def post_fetch_hook_for_show_method(_record, _conn) do
        "Override if needed"
      end

      defoverridable FatEcto.ShowRecord
    end
  end
end
