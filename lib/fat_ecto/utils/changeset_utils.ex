defmodule FatUtils.Changeset do
  @moduledoc """
    Provides different changeset methods.
  """

  @doc """
    Takes changeset and check if xor keys are present and return changeset error and also checks if xor keys are empty in the record and return error.
  """
  def xor(changeset, record, xor_keys, _options \\ []) do
    changeset =
      if FatUtils.Map.has_all_keys?(changeset.changes, xor_keys) do
        error_msg = Enum.join(xor_keys, " XOR ")

        Enum.reduce(xor_keys, changeset, fn xor_key, acc ->
          Ecto.Changeset.add_error(acc, xor_key, error_msg)
        end)
      else
        changeset
      end

    if !FatUtils.Map.has_any_of_keys?(changeset.changes, xor_keys) &&
         FatUtils.Map.has_all_val_equal_to?(record, xor_keys, nil) do
      require_msg = Enum.join(xor_keys, " XOR ") <> " fields can not be empty at the same time"

      Enum.reduce(xor_keys, changeset, fn xor_key, acc ->
        Ecto.Changeset.validate_required(
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
    If specific key is present in the changeset then other key passed as required will be set as required in the changeset.
  """

  def require_if_change_present(changeset, if_change_key: if_change_key, require_key: require_key) do
    if Map.has_key?(changeset.changes, if_change_key) do
      Ecto.Changeset.validate_required(
        changeset,
        require_key
      )
    else
      changeset
    end
  end

  @doc """
    Compare datetime fields and return error if start date is before end date and it can also compare time by passing compare_type: :time in options.
  """

  def validate_before(changeset, start_date_key, end_date_key, options \\ []) do
    start_date = Ecto.Changeset.get_field(changeset, start_date_key)
    end_date = Ecto.Changeset.get_field(changeset, end_date_key)

    {error_message_title, error_message} = error_msg_title(options, start_date_key, "must be before #{end_date_key}")

    cond do
      options[:compare_type] == :time ->
        if start_date && end_date && Time.diff(start_date, end_date) >= 0 do
          add_error(changeset, error_message_title, error_message)
        else
          changeset
        end

      true ->
        if start_date && end_date && DateTime.diff(start_date, end_date) >= 0 do
          add_error(changeset, error_message_title, error_message)
        else
          changeset
        end
    end
  end

  @doc """
    Compare datetime fields and return error if start date is before or equal end date and it can also compare time by passing compare_type: :time in options.
  """

  def validate_before_equal(changeset, start_date_key, end_date_key, options \\ []) do
    start_date = Ecto.Changeset.get_field(changeset, start_date_key)
    end_date = Ecto.Changeset.get_field(changeset, end_date_key)

    {error_message_title, error_message} =
      error_msg_title(options, start_date_key, "must be before or equal to #{end_date_key}")

    cond do
      options[:compare_type] == :time ->
        if start_date && end_date && Time.diff(start_date, end_date) > 0 do
          add_error(changeset, error_message_title, error_message)
        else
          changeset
        end

      true ->
        if start_date && end_date && DateTime.diff(start_date, end_date) > 0 do
          add_error(changeset, error_message_title, error_message)
        else
          changeset
        end
    end
  end

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
  def add_error(changeset, error_message_title, error_message \\ "is invalid") do
    Ecto.Changeset.add_error(changeset, error_message_title, error_message)
  end
end
