defmodule FatEcto.CreateMultipleRecord do
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
        def create(conn, [] = params) when is_list(params) do
          _create(conn, params)
        end
      else
        def create(conn, %{@wrapper => params}) when is_list(params) do
          _create(conn, params)
        end
      end

      defp _create(conn, params) do
        params = process_params_before_in_multiple_create(params, conn)
        changesets = multiple_changesets(params, conn)
        changesets = process_changesets_before_multiple_inserts(changesets, conn)

        # TODO: Support partial insert via options passed
        with {:ok, record} <- insert_records(changesets) do
          record = MacrosHelper.preload_record(record, @repo, @preloads)
          render_record(conn, record, unquote(options) ++ [status_to_put: :created])
        end
      end

      def multiple_changesets(params_array_for_records, _conn) do
        Enum.reduce(params_array_for_records, [], fn params_for_a_record, acc ->
          acc ++ [@schema.changeset(struct(@schema), params_for_a_record)]
        end)
      end

      def insert_records(changesets) when is_list(changesets) do
        multi =
          Enum.with_index(changesets)
          |> Enum.reduce(Ecto.Multi.new(), fn {cset, index}, multi ->
            Ecto.Multi.insert(multi, index, cset)
          end)

        case @repo.transaction(multi) do
          {:ok, data} ->
            records = Enum.reduce(data, [], fn {_index, record}, acc -> acc ++ [record] end)

            Enum.reduce(records, [], fn record, acc ->
              acc ++ [MacrosHelper.preload_record(record, @repo, @preloads)]
            end)

            {:ok, records}

          {:error, index, changeset, whatever} ->
            # You would need something like below in fallback controller
            # def call(conn, {:error, index, changeset = %Ecto.Changeset{}, _whatever}) do
            #   conn
            #   |> put_status(:unprocessable_entity)
            #   |> put_view(PogioApi.ErrorView)
            #   |> render("errors_with_index.json", %{code: 422, message: "Unprocessable entity", changeset: changeset, index: index})
            # end
            {:error, index, changeset, whatever}
        end
      end

      # You can use process_params_before_in_multiple_create to override params before calling changeset
      def process_params_before_in_multiple_create(params, _conn) do
        params
      end

      # You can use process_changesets_before_multiple_inserts to add/update/validate changeset before calling insert
      def process_changesets_before_multiple_inserts(changesets, _conn) do
        changesets
      end

      defoverridable process_params_before_in_multiple_create: 2,
                     process_changesets_before_multiple_inserts: 2,
                     insert_records: 1,
                     multiple_changesets: 2
    end
  end
end
