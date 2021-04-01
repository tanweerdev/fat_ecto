defmodule FatEcto.RenderUtils do
  defmacro __using__(options \\ []) do
    quote do
      @opt_app unquote(options)[:otp_app]
      @options (@opt_app &&
                  Keyword.merge(Application.get_env(@opt_app, FatEcto.RenderUtils) || [], unquote(options))) ||
                 unquote(options)

      def render_records(conn, records, meta, opts \\ []) do
        opts = Keyword.merge(@options, opts)

        put_view_module = opts[:put_view_module]
        view_to_render = opts[:view_to_render]
        data_to_view_as = opts[:data_to_view_as]
        status_to_put = opts[:status_to_put]
        meta_to_put_as = opts[:meta_to_put_as]

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

        case {view_to_render, data_to_view_as, meta_to_put_as} do
          {nil, nil, nil} ->
            render(conn, "index.json", data: records)

          {nil, nil, meta_to_put_as} when not is_nil(meta_to_put_as) ->
            render(conn, "index.json", %{:records => records, meta_to_put_as => meta, :options => opts})

          {nil, data_to_view_as, nil} when not is_nil(data_to_view_as) ->
            render(conn, "index.json", %{data_to_view_as => records, :meta => meta, :options => opts})

          {nil, data_to_view_as, meta_to_put_as} ->
            render(conn, "index.json", %{data_to_view_as => records, meta_to_put_as => meta, :options => opts})

          {view_to_render, nil, nil} ->
            render(conn, view_to_render, data: records)

          {view_to_render, nil, meta_to_put_as}
          when not is_nil(meta_to_put_as) and not is_nil(view_to_render) ->
            render(conn, view_to_render, %{:records => records, :options => opts, meta_to_put_as => meta})

          {view_to_render, data_to_view_as, nil}
          when not is_nil(data_to_view_as) and not is_nil(view_to_render) ->
            render(conn, view_to_render, %{data_to_view_as => records, :meta => meta, :options => opts})

          {view_to_render, data_to_view_as, meta_to_put_as} ->
            render(conn, view_to_render, %{
              data_to_view_as => records,
              meta_to_put_as => meta,
              :options => opts
            })
        end
      end

      def render_record(conn, record, opts \\ []) do
        opts = Keyword.merge(@options, opts)
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
          {nil, nil} -> render(conn, "show.json", data: record)
          {nil, data_to_view_as} -> render(conn, "show.json", %{data_to_view_as => record})
          {view_to_render, nil} -> render(conn, view_to_render, data: record)
          {view_to_render, data_to_view_as} -> render(conn, view_to_render, %{data_to_view_as => record})
        end
      end

      def errors_changeset(conn, changeset, opts \\ []) do
        opts = Keyword.merge(@options, opts)
        put_view_module = opts[:put_view_module]
        status_to_put = opts[:status_to_put]
        view_to_render = opts[:view_to_render]
        data_to_view_as = opts[:data_to_view_as]

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
            render(conn, "errors.json", code: 422, message: "Unprocessable entity", changeset: changeset)

          {nil, data_to_view_as} ->
            render(conn, "errors.json", %{data_to_view_as => changeset})

          {view_to_render, nil} ->
            render(conn, view_to_render, changeset: changeset)

          {view_to_render, data_to_view_as} ->
            render(conn, view_to_render, %{data_to_view_as => changeset})
        end
      end

      def render_resp(conn, msg, status_to_put, opts \\ []) do
        opts = Keyword.merge(@options, opts)
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

      defoverridable render_resp: 4, errors_changeset: 3, render_record: 3
    end
  end
end
