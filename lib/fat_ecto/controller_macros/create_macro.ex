defmodule FatEcto.CreateRecord do
  @moduledoc false

  defmacro __using__(options) do
    quote do
      alias FatEcto.MacrosHelper
      @repo unquote(options)[:repo]
      @preloads unquote(options)[:preloads]

      if !@repo do
        raise "please define repo when using create record"
      end

      @schema unquote(options)[:schema]

      if !@schema do
        raise "please define schema when using create record"
      end

      @wrapper unquote(options)[:wrapper]

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
        params = process_params_before_in_create(params)
        changeset = @schema.changeset(struct(@schema), params)
        changeset = process_changeset_before_insert(changeset)

        with {:ok, record} <- @repo.insert(changeset) do
          record = MacrosHelper.preload_record(record, @repo, @preloads)
          render_record(conn, record, unquote(options) ++ [status_to_put: :created])
        end
      end

      def process_params_before_in_create(params) do
        params
      end

      def process_changeset_before_insert(changeset) do
        changeset
      end

      defoverridable process_params_before_in_create: 1, process_changeset_before_insert: 1
    end
  end
end
