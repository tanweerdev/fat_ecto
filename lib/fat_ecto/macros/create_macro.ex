defmodule FatEcto.CreateRecord do
  @moduledoc false

  defmacro __using__(options) do
    quote do
      @repo unquote(options)[:repo]

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
        changeset = @schema.changeset(struct(@schema), params)

        with {:ok, record} <- @repo.insert(changeset) do
          render_record(conn, record, unquote(options) ++ [status_to_put: :created])
        end
      end
    end
  end
end
