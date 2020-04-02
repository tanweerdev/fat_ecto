defmodule FatEcto.ShowRecord do
  @moduledoc false

  defmacro __using__(options) do
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

      @preloads unquote(options)[:preloads]

      def show(conn, %{"id" => id}) do
        case MacrosHelper.get_record(id, @repo, @schema) do
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
            render_record(conn, record, unquote(options) ++ [status_to_put: :ok])
        end
      end
    end
  end
end
