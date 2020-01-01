defmodule FatEcto.CreateRecord do
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
          conn
          |> put_status(:created)
          |> render("show.json", data: record)
        end
      end
    end
  end
end
