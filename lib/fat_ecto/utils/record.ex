defmodule FatUtils.FatRecord do
  defmacro __using__(options) do
    quote location: :keep do
      @moduledoc """
      Record related utils.

      `import` or `alias` it inside your module.
      """

      @opt_app unquote(options)[:otp_app]
      if !@opt_app do
        raise "please define opt app when using fat query methods"
      end

      @options Keyword.merge(Application.get_env(@opt_app, :fat_ecto) || [], unquote(options))
      @encoder_library @options[:encoder_library]

      if !@encoder_library do
        raise "please define encoder_library when using fat record utils"
      end

      def sanitize_map(records) when is_list(records) do
        Enum.reduce(records, [], fn rec, acc ->
          acc ++ [sanitize_map(rec)]
        end)
      end

      def sanitize_map(record) when is_tuple(record) do
        case tuple_size(record) do
          2 ->
            [key, value] = Tuple.to_list(record)
            %{key => sanitize_map(value)}

          _size ->
            record
            |> Tuple.to_list()
            |> @encoder_library.Encoder.List.encode([])
        end
      end

      @doc """
       Takes a map, list of maps, tuple and remove struct field, meta field and not loaded assocations.
      """
      def sanitize_map(record) when is_map(record) do
        schema_keys = [:__struct__, :__meta__]

        Enum.reduce(Map.drop(record, schema_keys), %{}, fn {k, v}, acc ->
          cond do
            is_list(v) && List.first(v) && is_map(List.first(v)) &&
                Enum.all?(schema_keys, &Map.has_key?(List.first(v), &1)) ->
              values =
                Enum.reduce(v, [], fn rec, acc ->
                  acc ++ [sanitize_map(rec)]
                end)

              Map.put(acc, k, values)

            (is_map(v) && Map.has_key?(v, :__struct__) && Ecto.assoc_loaded?(v)) || !is_map(v) ->
              Map.put(
                acc,
                k,
                if(
                  is_map(v) && Enum.all?(schema_keys, &Map.has_key?(v, &1)),
                  do: sanitize_map(v),
                  else: v
                )
              )

            true ->
              acc
          end
        end)
      end

      def sanitize_map(record) do
        record
      end
    end
  end
end
