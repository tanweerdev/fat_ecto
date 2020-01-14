defmodule FatEcto.Render do
  defmacro __using__(_options) do
    quote do
      def render_record(conn, record, opts) do
        put_view_module = opts[:put_view_module]
        view_to_render = opts[:view_to_render]
        data_to_view_as = opts[:data_to_view_as]
        status_to_put = opts[:status_to_put]

        conn =
          if put_view_module do
            put_view(conn, put_view_module)
          else
            conn
          end

        conn =
          if status_to_put do
            put_status(conn, status_to_put)
          else
            conn
          end

        case {view_to_render, data_to_view_as} do
          {nil, nil} ->
            conn
            |> render("show.json", data: record)

          {nil, data_to_view_as} ->
            conn
            |> render("show.json", {data_to_view_as, record})

          {view_to_render, nil} ->
            conn
            |> render(view_to_render, data: record)

          {view_to_render, data_to_view_as} ->
            conn
            |> render(view_to_render, {data_to_view_as, record})
        end
      end

      def render_resp(conn, msg, status_to_put, opts) do
        put_content_type = opts[:put_content_type]

        conn =
          if put_content_type do
            put_resp_content_type(conn, put_content_type)
          else
            conn
          end

        msg = Jason.encode!(msg)

        conn
        |> send_resp(status_to_put, msg)
      end
    end
  end
end
