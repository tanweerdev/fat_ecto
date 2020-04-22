defmodule FatEcto.CreateRecord do
  @moduledoc false

  defmacro __using__(options) do
    quote location: :keep do
      alias FatEcto.MacrosHelper
      @repo unquote(options)[:repo]
      @preloads unquote(options)[:preloads] || []

      if !@repo do
        raise "please define repo when using create record"
      end

      @schema unquote(options)[:schema]

      if !@schema do
        raise "please define schema when using create record"
      end

      @wrapper unquote(options)[:wrapper]
      @custom_changeset unquote(options)[:custom_changeset]
      if @wrapper in [nil, ""] do
        def create(conn, %{} = params) do
          _craete(conn, params)
        end
      else
        def create(conn, %{@wrapper => params}) do
          _craete(conn, params)
        end
      end

      defp _craete(conn, params) do
        params = process_params_before_in_create(params, conn)
        changeset = build_insert_changeset(@custom_changeset, params)
        changeset = process_changeset_before_insert(changeset, params, conn)

        with {:ok, record} <- insert_record(changeset, @repo) do
          record = MacrosHelper.preload_record(record, @repo, @preloads)
          after_create_hook_for_create(record, conn)
          render_record(conn, record, [status_to_put: :created] ++ unquote(options))
        end
      end

      def insert_record(changeset, repo) do
        repo.insert(changeset)
      end

      # You can use process_params_before_in_create to override params before calling changeset
      def process_params_before_in_create(params, _conn) do
        params
      end

      # You can use process_changeset_before_insert to add/update/validate changeset before calling insert
      def process_changeset_before_insert(changeset, _params, _conn) do
        changeset
      end

      # You can use after_create_hook_for_create to log etc
      def after_create_hook_for_create(_record, _conn) do
        "Override if needed"
      end

      defp build_insert_changeset(cs, params) when is_nil(cs), do: @schema.changeset(struct(@schema), params)

      defp build_insert_changeset(cs, params) when is_function(cs, 2) do
        cs.(struct(@schema), params)
      end

      defp build_insert_changeset(cs, _params), do: cs

      defoverridable process_params_before_in_create: 2,
                     process_changeset_before_insert: 3,
                     insert_record: 2,
                     after_create_hook_for_create: 2
    end
  end
end
