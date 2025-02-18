defmodule FatUtils.Changeset do
  @moduledoc """
  Provides utility functions for validating Ecto changesets.

  This module includes functions for validating XOR conditions, requiring specific fields,
  and comparing datetime fields.
  """

  import Ecto.Changeset

  @doc """
  Validates that only one of the specified XOR keys is present in the changeset.

  ## Parameters
  - `changeset`: The Ecto changeset.
  - `record`: The original record (used to check if all XOR keys are empty).
  - `xor_keys`: A list of keys to validate as XOR.
  - `options`: Additional options (currently unused).

  ## Examples
      iex> import Ecto.Changeset
      iex> changeset = cast(%FatEcto.FatUser{}, %{field1: "value1", field2: "value2"}, [:field1, :field2])
      iex> FatUtils.Changeset.validate_xor_fields(changeset, %FatEcto.FatUser{}, [:field1, :field2])
      #Ecto.Changeset<...>
  """
  @spec validate_xor_fields(Ecto.Changeset.t(), map(), list(atom()), keyword()) :: Ecto.Changeset.t()
  def validate_xor_fields(changeset, record, xor_keys, _options \\ []) do
    changeset =
      if FatUtils.Map.has_all_keys?(changeset.changes, xor_keys) do
        error_msg = Enum.join(xor_keys, " XOR ")
        Enum.reduce(xor_keys, changeset, &add_error(&2, &1, error_msg))
      else
        changeset
      end

    if !FatUtils.Map.has_any_of_keys?(changeset.changes, xor_keys) &&
         FatUtils.Map.has_all_val_equal_to?(record, xor_keys, nil) do
      require_msg = Enum.join(xor_keys, " XOR ") <> " fields cannot be empty at the same time"
      Enum.reduce(xor_keys, changeset, &validate_required(&2, [&1], message: require_msg))
    else
      changeset
    end
  end

  @doc """
  Validates that only one of the specified keys is present in the changeset.

  ## Parameters
  - `changeset`: The Ecto changeset.
  - `record`: The original record (currently unused).
  - `single_keys`: A list of keys to validate.
  - `options`: Additional options (currently unused).

  ## Examples
      iex> import Ecto.Changeset
      iex> changeset = cast(%FatEcto.FatUser{}, %{field1: "value1"}, [:field1, :field2])
      iex> FatUtils.Changeset.validate_only_one_field(changeset, %FatEcto.FatUser{}, [:field1, :field2])
      #Ecto.Changeset<...>
  """
  @spec validate_only_one_field(Ecto.Changeset.t(), map(), list(atom()), keyword()) :: Ecto.Changeset.t()
  def validate_only_one_field(changeset, _record, single_keys, _options \\ []) do
    keys_count = Enum.count(single_keys, &get_field(changeset, &1))

    if keys_count == 1 do
      changeset
    else
      error_msg = format_error_message(single_keys)
      Enum.reduce(single_keys, changeset, &add_error(&2, &1, "only one of #{error_msg} is required"))
    end
  end

  @doc """
  Validates that at least one of the specified OR keys is present in the changeset.

  ## Parameters
  - `changeset`: The Ecto changeset.
  - `record`: The original record (currently unused).
  - `or_keys`: A list of keys to validate.
  - `options`: Additional options (currently unused).

  ## Examples
      iex> import Ecto.Changeset
      iex> changeset = cast(%FatEcto.FatUser{}, %{}, [:field1, :field2])
      iex> FatUtils.Changeset.validate_at_least_one_field(changeset, %FatEcto.FatUser{}, [:field1, :field2])
      #Ecto.Changeset<...>
  """
  @spec validate_at_least_one_field(Ecto.Changeset.t(), map(), list(atom()), keyword()) :: Ecto.Changeset.t()
  def validate_at_least_one_field(changeset, _record, or_keys, _options \\ []) do
    if FatUtils.Map.has_any_of_keys?(changeset.changes, or_keys) do
      changeset
    else
      error_msg = Enum.join(or_keys, " OR ")
      Enum.reduce(or_keys, changeset, &add_error(&2, &1, "#{error_msg} required"))
    end
  end

  @doc """
  Makes a field required if another field is present in the changeset.

  ## Parameters
  - `changeset`: The Ecto changeset.
  - `if_change_key`: The key to check for presence.
  - `require_key`: The key to make required.

  ## Examples
      iex> import Ecto.Changeset
      iex> changeset = cast(%FatEcto.FatUser{}, %{field1: "value1"}, [:field1, :field2])
      iex> FatUtils.Changeset.require_field_if_present(changeset, if_change_key: :field1, require_key: :field2)
      #Ecto.Changeset<...>
  """
  @spec require_field_if_present(Ecto.Changeset.t(), keyword()) :: Ecto.Changeset.t()
  def require_field_if_present(changeset, if_change_key: if_change_key, require_key: require_key) do
    if Map.has_key?(changeset.changes, if_change_key) do
      validate_required(changeset, [require_key])
    else
      changeset
    end
  end

  @doc """
  Validates that a start date/time is before an end date/time.

  ## Parameters
  - `changeset`: The Ecto changeset.
  - `start_date_key`: The key for the start date/time.
  - `end_date_key`: The key for the end date/time.
  - `options`: Options to customize the error message or specify comparison type (`:time` or `:datetime`).

  ## Examples
      iex> import Ecto.Changeset
      iex> changeset = cast(%FatEcto.FatUser{}, %{start_time: ~T[10:00:00], end_time: ~T[09:00:00]}, [:start_time, :end_time])
      iex> FatUtils.Changeset.validate_start_before_end(changeset, :start_time, :end_time, compare_type: :time)
      #Ecto.Changeset<...>
  """
  @spec validate_start_before_end(Ecto.Changeset.t(), atom(), atom(), keyword()) :: Ecto.Changeset.t()
  def validate_start_before_end(changeset, start_date_key, end_date_key, options \\ []) do
    start_date = get_field(changeset, start_date_key)
    end_date = get_field(changeset, end_date_key)

    if start_date && end_date && !before?(start_date, end_date, options[:compare_type]) do
      {error_message_title, error_message} =
        error_msg_title(options, start_date_key, "must be before #{end_date_key}")

      add_custom_error(changeset, error_message_title, error_message)
    else
      changeset
    end
  end

  @doc """
  Validates that a start date/time is before or equal to an end date/time.

  ## Parameters
  - `changeset`: The Ecto changeset.
  - `start_date_key`: The key for the start date/time.
  - `end_date_key`: The key for the end date/time.
  - `options`: Options to customize the error message or specify comparison type (`:time` or `:datetime`).

  ## Examples
      iex> import Ecto.Changeset
      iex> changeset = cast(%FatEcto.FatUser{}, %{start_time: ~T[10:00:00], end_time: ~T[10:00:00]}, [:start_time, :end_time])
      iex> FatUtils.Changeset.validate_start_before_or_equal_end(changeset, :start_time, :end_time, compare_type: :time)
      #Ecto.Changeset<...>
  """
  @spec validate_start_before_or_equal_end(Ecto.Changeset.t(), atom(), atom(), keyword()) ::
          Ecto.Changeset.t()
  def validate_start_before_or_equal_end(changeset, start_date_key, end_date_key, options \\ []) do
    start_date = get_field(changeset, start_date_key)
    end_date = get_field(changeset, end_date_key)

    if start_date && end_date && !before_or_equal?(start_date, end_date, options[:compare_type]) do
      {error_message_title, error_message} =
        error_msg_title(options, start_date_key, "must be before or equal to #{end_date_key}")

      add_custom_error(changeset, error_message_title, error_message)
    else
      changeset
    end
  end

  @doc """
  Adds a custom error to the changeset.

  ## Parameters
  - `changeset`: The Ecto changeset.
  - `error_message_title`: The field or title for the error.
  - `error_message`: The error message (default: "is invalid").

  ## Examples
      iex> import Ecto.Changeset
      iex> changeset = cast(%FatEcto.FatUser{}, %{}, [])
      iex> FatUtils.Changeset.add_custom_error(changeset, :field, "custom error")
      #Ecto.Changeset<...>
  """
  @spec add_custom_error(Ecto.Changeset.t(), atom(), String.t()) :: Ecto.Changeset.t()
  def add_custom_error(changeset, error_message_title, error_message \\ "is invalid") do
    add_error(changeset, error_message_title, error_message)
  end

  # Helper functions

  defp before?(start_date, end_date, :time), do: Time.diff(start_date, end_date) < 0
  defp before?(start_date, end_date, _), do: DateTime.diff(start_date, end_date) < 0

  defp before_or_equal?(start_date, end_date, :time), do: Time.diff(start_date, end_date) <= 0
  defp before_or_equal?(start_date, end_date, _), do: DateTime.diff(start_date, end_date) <= 0

  defp format_error_message(keys) do
    case Enum.split(keys, -2) do
      {[], [last]} -> Atom.to_string(last)
      {[], [second_last, last]} -> "#{second_last} or #{last}"
      {first_keys, [second_last, last]} -> Enum.join(first_keys, ", ") <> ", #{second_last} or #{last}"
    end
  end

  defp error_msg_title(options, field_key, default_error_msg) do
    {
      options[:error_message_title] || field_key,
      options[:error_message] || default_error_msg
    }
  end
end
