defmodule FatUtils.SeedHelper do
  @moduledoc false

  defmacro __using__(options) do
    quote do
      use Ecto.Migration

      @opt_app unquote(options)[:otp_app]
      if !@opt_app do
        raise "please define opt app when using fat seed helpers"
      end

      @options Keyword.merge(Application.get_env(@opt_app, :fat_ecto) || [], unquote(options))
      @seed_base_path @options[:seed_base_path]

      if !@seed_base_path do
        raise "please define seed_base_path when using fat seed utils"
      end

      @doc """
       Map csv data to table inside migrations.
      ### Parameters

        - `csv_path`                     - Name of the csv file without csv extention.
        - `callback`                     - map_to_table function.
        - `should_coonvert_empty_to_nil` - Convert empty values to nil if pass true.
        - `base_path`                    - base path of the csv file.

      """
      def import_from_csv(
            csv_path,
            callback,
            should_coonvert_empty_to_nil \\ false,
            base_path \\ nil
          ) do
        base_path =
          if base_path == nil,
            do: @seed_base_path,
            else: base_path

        (csv_path <> ".csv")
        |> Path.expand(base_path)
        |> File.stream!()
        |> CSV.decode!(headers: true)
        |> Stream.each(fn row ->
          row
          |> map_escap_sql(should_coonvert_empty_to_nil)
          |> callback.()
        end)
        |> Stream.run()
      end

      @doc """
        Convert empty values to null or convert them accordingly.
      ### Parameters

        - `map`                          - Map containing the row of the csv file.
        - `should_coonvert_empty_to_nil` - Convert empty values to nil if pass true.
        
      ### Examples
      ```
      iex> map = %{ "two" => ""}
      iex> #{__MODULE__}.map_escap_sql(map, true)
      %{"two" => "null"}
      iex> #{__MODULE__}.map_escap_sql(map, false)
      %{"two" => "''"}
      ```
      """
      def map_escap_sql(map, should_coonvert_empty_to_nil) do
        for {key, value} <- map, into: %{} do
          case value do
            "null" ->
              {key, value}

            "" ->
              if should_coonvert_empty_to_nil do
                {key, "null"}
              else
                value =
                  value
                  |> String.replace("'", "''")

                {key, ~s('#{value}')}
              end

            _ ->
              value =
                value
                |> String.replace("'", "''")

              {key, ~s('#{value}')}
          end
        end
      end

      @doc """
       Map csv data to table inside migrations.
      ### Parameters

        - `map`        - Map of the csv rows.
        - `table`      - Table name.

      """
      def map_to_table(map, table) do
        keys =
          map
          |> Map.keys()
          |> Enum.join(~s(", "))

        values =
          map
          |> Map.values()
          |> Enum.join(", ")

        Ecto.Migration.execute("INSERT INTO #{table} (\"#{keys}\") values (#{values})")
      end

      @doc """
        Reset id sequence inside migrations for a table.
      ### Parameters

         - `id`         - id of the table.
         - `table`      - Table name.

      """
      def reset_id_seq(table, id \\ "id") do
        Ecto.Migration.execute("SELECT setval('#{table}_#{id}_seq', (SELECT MAX(#{id}) from \"#{table}\"));")
      end
    end
  end
end
