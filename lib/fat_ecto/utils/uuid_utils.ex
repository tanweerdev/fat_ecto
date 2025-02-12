defmodule FatUtils.UUID do
  @moduledoc """
  Provides utility functions for working with UUIDs.

  This module includes functions to validate and parse UUIDs from a map of parameters.
  """

  alias Ecto.UUID

  @doc """
  Parses and validates UUIDs in a map of parameters.

  This function takes a map of parameters, a list of fields that should contain UUIDs,
  and an optional list of options. It returns a tuple containing a list of invalid UUID fields
  and a map of valid parameters.

  ## Parameters
    - `params`: A map of parameters.
    - `list_of_uuid_fields`: A list of fields (keys) in the map that should contain UUIDs.
    - `options`: A keyword list of options. Supported options:
      - `:valid_values`: A list of values that are considered valid without UUID validation.

  ## Returns
    - `{invalid_uuids, valid_params}`: A tuple where:
      - `invalid_uuids` is a list of fields that contain invalid UUIDs.
      - `valid_params` is a map of parameters with valid UUIDs.

  ## Examples
      iex> params = %{user_id: "123e4567-e89b-12d3-a456-426614174000", post_id: "invalid-uuid"}
      iex> FatUtils.UUID.parse(params, [:user_id, :post_id])
      {[:post_id], %{user_id: "123e4567-e89b-12d3-a456-426614174000"}}

      iex> params = %{user_id: "123e4567-e89b-12d3-a456-426614174000", role: "admin"}
      iex> FatUtils.UUID.parse(params, [:user_id], valid_values: ["admin"])
      {[], %{user_id: "123e4567-e89b-12d3-a456-426614174000", role: "admin"}}
  """
  @spec parse(params :: map(), list_of_uuid_fields :: [atom()], options :: keyword()) ::
          {invalid_uuids :: [atom()], valid_params :: map()}
  def parse(params, list_of_uuid_fields, options \\ []) when is_map(params) do
    valid_values = Keyword.get(options, :valid_values, [])

    Enum.reduce(params, {[], %{}}, fn {key, value}, {invalid_uuids, valid_params} ->
      cond do
        # Skip validation if the value is in the valid_values list
        value in valid_values ->
          {invalid_uuids, Map.put(valid_params, key, value)}

        # Validate UUID if the key is in the list_of_uuid_fields
        key in list_of_uuid_fields ->
          case UUID.cast(value) do
            {:ok, _valid_uuid} -> {invalid_uuids, Map.put(valid_params, key, value)}
            :error -> {[key | invalid_uuids], valid_params}
          end

        # Keep the key-value pair as is if it's not a UUID field
        true ->
          {invalid_uuids, Map.put(valid_params, key, value)}
      end
    end)
  end
end
