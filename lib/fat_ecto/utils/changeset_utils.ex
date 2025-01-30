defmodule FatUtils.Changeset do
  @moduledoc """
    Provides different changeset methods.
  """
  import Ecto.Changeset

  @doc """
    Takes changeset and check if xor keys are present and return changeset error and also checks if xor keys are empty in the record and return error.
  """
  @spec validate_xor(any(), any(), any(), any()) :: any()
  def validate_xor(changeset, record, xor_keys, _options \\ []) do
    changeset =
      if FatUtils.Map.has_all_keys?(changeset.changes, xor_keys) do
        error_msg = Enum.join(xor_keys, " XOR ")

        Enum.reduce(xor_keys, changeset, fn xor_key, acc ->
          add_error(acc, xor_key, error_msg)
        end)
      else
        changeset
      end

    if !FatUtils.Map.has_any_of_keys?(changeset.changes, xor_keys) &&
         FatUtils.Map.has_all_val_equal_to?(record, xor_keys, nil) do
      require_msg = Enum.join(xor_keys, " XOR ") <> " fields can not be empty at the same time"

      Enum.reduce(xor_keys, changeset, fn xor_key, acc ->
        validate_required(
          acc,
          [xor_key],
          message: require_msg
        )
      end)
    else
      changeset
    end
  end

  @doc """
   Takes changeset and check if one of the key is present and return changeset error.
  """
  @spec require_only_one_of(any(), any(), any(), any()) :: any()
  def require_only_one_of(changeset, _record, single_keys, _options \\ []) do
    keys_count =
      Enum.reduce(single_keys, 0, fn sk, acc ->
        if get_field(changeset, sk) do
          acc + 1
        else
          acc
        end
      end)

    if keys_count == 1 do
      changeset
    else
      first_keys = Enum.drop(single_keys, -2)
      first_keys = Enum.join(first_keys, ",")
      last_two_elements = Enum.slice(single_keys, -2, 2)
      last_two_elements = Enum.join(last_two_elements, " or ")

      error_msg = first_keys <> ", " <> last_two_elements
      error_msg = String.trim_leading(error_msg, ", ")

      Enum.reduce(single_keys, changeset, fn single_key, acc ->
        add_error(acc, single_key, "only one of " <> error_msg <> " is required")
      end)
    end
  end

  @doc """
    Takes changeset and check if none of or keys are present and return changeset error.
  """
  @spec require_or(any(), any(), any(), any()) :: any()
  def require_or(changeset, _record, or_keys, _options \\ []) do
    if FatUtils.Map.has_any_of_keys?(changeset.changes, or_keys) do
      changeset
    else
      error_msg = Enum.join(or_keys, " OR ")

      Enum.reduce(or_keys, changeset, fn or_key, acc ->
        add_error(acc, or_key, error_msg <> " required")
      end)
    end
  end

  @spec require_if_change_present(any(), [{:if_change_key, any()} | {:require_key, any()}, ...]) :: any()
  @doc """
    If specific key is present in the changeset then other key passed as required will be set as required in the changeset.
  """

  def require_if_change_present(changeset, if_change_key: if_change_key, require_key: require_key) do
    if Map.has_key?(changeset.changes, if_change_key) do
      validate_required(
        changeset,
        require_key
      )
    else
      changeset
    end
  end

  @spec validate_before(Ecto.Changeset.t(), atom(), atom(), nil | maybe_improper_list() | map()) ::
          Ecto.Changeset.t()
  @doc """
    Compare datetime fields and return error if start date is before end date and it can also compare time by passing compare_type: :time in options.
  """

  def validate_before(changeset, start_date_key, end_date_key, options \\ []) do
    start_date = get_field(changeset, start_date_key)
    end_date = get_field(changeset, end_date_key)

    {error_message_title, error_message} =
      error_msg_title(options, start_date_key, "must be before #{end_date_key}")

    if options[:compare_type] == :time do
      if start_date && end_date && Time.diff(start_date, end_date) >= 0 do
        add_custom_error(changeset, error_message_title, error_message)
      else
        changeset
      end
    else
      if start_date && end_date && DateTime.diff(start_date, end_date) >= 0 do
        add_custom_error(changeset, error_message_title, error_message)
      else
        changeset
      end
    end
  end

  @doc """
    Compare datetime fields and return error if start date is before or equal end date and it can also compare time by passing compare_type: :time in options.
  """
  @spec validate_before_equal(Ecto.Changeset.t(), atom(), atom(), nil | maybe_improper_list() | map()) ::
          Ecto.Changeset.t()

  def validate_before_equal(changeset, start_date_key, end_date_key, options \\ []) do
    start_date = get_field(changeset, start_date_key)
    end_date = get_field(changeset, end_date_key)

    {error_message_title, error_message} =
      error_msg_title(options, start_date_key, "must be before or equal to #{end_date_key}")

    if options[:compare_type] == :time do
      if start_date && end_date && Time.diff(start_date, end_date) > 0 do
        add_custom_error(changeset, error_message_title, error_message)
      else
        changeset
      end
    else
      if start_date && end_date && DateTime.diff(start_date, end_date) > 0 do
        add_custom_error(changeset, error_message_title, error_message)
      else
        changeset
      end
    end
  end

  @spec error_msg_title(nil | maybe_improper_list() | map(), any(), any()) :: {any(), any()}
  @doc """
  Add custom error message with field and error message.
  """

  def error_msg_title(options, field_key, default_error_msg) do
    error_message_title =
      if options[:error_message_title] do
        options[:error_message_title]
      else
        field_key
      end

    error_message =
      if options[:error_message] do
        options[:error_message]
      else
        default_error_msg
      end

    {error_message_title, error_message}
  end

  @doc """
    Add custom error to changeset. If custom message is not provided default one will be used.
  """
  @spec add_custom_error(Ecto.Changeset.t(), atom(), binary()) :: Ecto.Changeset.t()
  def add_custom_error(changeset, error_message_title, error_message \\ "is invalid") do
    add_error(changeset, error_message_title, error_message)
  end
end
