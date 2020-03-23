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
      @paginator unquote(options)[:paginator]

      def index(conn, params) do
        query = if @preloads do
          Ecto.Query.preload(@schema, ^@preloads)
        else
          @schema
        end

        if @paginator do
          {records, meta} = @paginator.paginate_get_records(query, params)
          render_records(conn, records, meta, unquote(options))
        else
          records = @repo.all(query)
          render_records(conn, records, nil, unquote(options))
        end
      end

      def render_records(conn, records, meta, opts \\ []) do
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
          {nil, nil, nil} -> render(conn, "index.json", data: records)
          {nil, data_to_view_as, nil} -> render(conn, "index.json", %{records: records, options: unquote(options)})
          {nil, data_to_view_as, meta_to_put_as} -> render(conn, "index.json", %{records: records, meta: meta, options: unquote(options)})
          {view_to_render, nil} -> render(conn, view_to_render, data: records)
          {view_to_render, data_to_view_as} -> render(conn, view_to_render, %{data_to_view_as => records})
        end
      end
    end
  end
end
