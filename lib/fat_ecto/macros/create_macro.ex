defmodule FatEcto.CreateRecord do
  @moduledoc """
  ### Create

  #### Note: Either use `use FatEcto.Render` or write your own views.

  ### Parameters

  - `repo`- repository name.
  - `schema` - schema name.

  ```elixir
  use FatEcto.CreateRecord, repo: repo_name,  schema: schema_name
  ```
  you just need to pass `repo_name` and `schema_name`.

  #### Example

  ```elixir
  defmodule DemoWeb.MemberController do

    use DemoWeb, :controller
    use FatEcto.CreateRecord, repo: Demo.Repo,  schema: Demo.Member

  end
  ```
  """

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
