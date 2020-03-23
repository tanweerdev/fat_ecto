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
        query =
          if @preloads do
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
    end
  end
end
