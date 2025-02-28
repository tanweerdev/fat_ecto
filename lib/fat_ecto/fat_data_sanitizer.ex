defmodule FatEcto.FatDataSanitizer do
  @moduledoc """
  Provides functionality to sanitize records and convert data into views.

  This module can be used to clean up records by removing sensitive data, masking specific fields,
  and customizing the output based on options.
  """

  defmacro __using__(_options) do
    quote location: :keep do
      @doc """
      Sanitizes the given record or list of records.

      ## Parameters
      - `record/records`: A map, list of maps, or tuple.
      - `opts`: A keyword list of options:
        - `:mask`: A list of keys whose values should be masked (e.g., `[card_number: "****"]`).
        - `:remove`: A list of keys to remove from the final result.
        - `:only`: A list of keys to include in the final result (all others are excluded).
        - `:except`: A list of keys to exclude from the final result.

      ## Examples

          iex> record = %{name: "John", card_number: "1234-5678-9012-3456", ssn: "123-45-6789"}
          iex> sanitized = FatEcto.TestRecordUtils.sanitize(record, mask: [card_number: "****"], remove: [:ssn])
          iex> sanitized
          %{name: "John", card_number: "****"}
      """
      def sanitize(record_or_records, opts \\ [])

      def sanitize(records, opts) when is_list(records) do
        Enum.map(records, &sanitize_record(&1, opts))
      end

      def sanitize(record, opts) when is_tuple(record) do
        sanitize_tuple(record, opts)
      end

      def sanitize(record, opts) when is_map(record) do
        sanitize_record(record, opts)
      end

      def sanitize(record, _opts), do: record

      defp sanitize_record(record, opts) do
        record
        |> remove_keys(opts[:remove])
        |> mask_values(opts[:mask])
        |> filter_keys(opts[:only], opts[:except])
        |> sanitize_map(opts)
      end

      defp sanitize_tuple(record, opts) when is_tuple(record) do
        case tuple_size(record) do
          2 ->
            [key, value] = Tuple.to_list(record)
            %{key => sanitize(value, opts)}

          _size ->
            encoder_library = Application.get_env(:fat_ecto, :json_library, Jason)

            unless encoder_library do
              raise "Please define :json_library in :fat_ecto configuration"
            end

            record
            |> Tuple.to_list()
            |> encoder_library.encode!(get_encoder_opts(encoder_library))
        end
      end

      defp get_encoder_opts(Jason), do: []
      defp get_encoder_opts(_), do: []

      defp sanitize_map(record, opts) when is_map(record) do
        schema_keys = [:__struct__, :__meta__]

        record
        |> Map.drop(schema_keys)
        |> Enum.reduce(%{}, fn {k, v}, acc ->
          cond do
            # Skip unloaded associations
            match?(%Ecto.Association.NotLoaded{}, v) ->
              acc

            is_list(v) ->
              Map.put(acc, k, Enum.map(v, &sanitize_record(&1, opts)))

            is_map(v) ->
              Map.put(acc, k, sanitize_map(v, opts))

            is_tuple(v) ->
              Map.put(acc, k, sanitize_tuple(v, opts))

            true ->
              Map.put(acc, k, v)
          end
        end)
      end

      defp remove_keys(record, nil), do: record

      defp remove_keys(record, keys_to_remove) when is_list(keys_to_remove) do
        Map.drop(record, keys_to_remove)
      end

      defp mask_values(record, nil), do: record

      defp mask_values(record, mask_rules) when is_list(mask_rules) do
        Enum.reduce(mask_rules, record, fn {key, mask}, acc ->
          if Map.has_key?(acc, key), do: Map.put(acc, key, mask), else: acc
        end)
      end

      defp filter_keys(record, nil, nil), do: record

      defp filter_keys(record, only_keys, nil) when is_list(only_keys) do
        Map.take(record, only_keys)
      end

      defp filter_keys(record, nil, except_keys) when is_list(except_keys) do
        Map.drop(record, except_keys)
      end

      defp filter_keys(record, _only_keys, _except_keys), do: record

      defoverridable sanitize: 2,
                     sanitize_record: 2,
                     sanitize_tuple: 2,
                     sanitize_map: 2,
                     remove_keys: 2,
                     mask_values: 2,
                     filter_keys: 3
    end
  end
end
