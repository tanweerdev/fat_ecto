defmodule FatEcto.SharedHelper do
  @moduledoc """
  Provides utility functions for FatEcto, including handling pagination limits, skip values,
  dynamic binding, and preloading associations.
  """

  @doc """
  Checks if a module implements the given behaviour by inspecting its `__info__/1` metadata.

  ## Parameters
  - `module`: The module to check.
  - `behaviour`: The behaviour to validate against.

  ## Examples
      iex> implements_behaviour?(MyApp.Repo, Ecto.Repo)
      true

      iex> implements_behaviour?(NotARepo, Ecto.Repo)
      false
  """
  @spec implements_behaviour?(module(), module()) :: boolean()
  def implements_behaviour?(module, behaviour) do
    is_atom(module) &&
      Code.ensure_compiled(module) &&
      function_exported?(module, :__info__, 1) &&
      :attributes
      |> module.__info__()
      |> Keyword.get(:behaviour, [])
      |> Enum.member?(behaviour)
  end

  @doc """
  Converts a string to an atom.

  ## Parameters
  - `str`: The string to convert.

  ## Examples
      iex> FatEcto.SharedHelper.string_to_atom("example")
      :example
  """
  # 1 TODO: maybe remove this method as its dangerous
  @spec string_to_atom(String.t() | atom()) :: atom()
  def string_to_atom(already_atom) when is_atom(already_atom), do: already_atom
  def string_to_atom(str), do: String.to_atom(str)

  @doc """
  Converts a string to an existing atom.

  ## Parameters
  - `str`: The string to convert.

  ## Examples
      iex> FatEcto.SharedHelper.string_to_existing_atom("example")
      :example
  """
  @spec string_to_existing_atom(String.t() | atom()) :: atom()
  def string_to_existing_atom(already_atom) when is_atom(already_atom), do: already_atom
  def string_to_existing_atom(str), do: String.to_existing_atom(str)

  @doc """
  Retrieves the primary keys for a given query.

  ## Parameters
  - `query`: The Ecto query.

  ## Examples
      iex> FatEcto.SharedHelper.get_primary_keys(from(u in User))
      [:id]
  """
  @spec get_primary_keys(Ecto.Query.t()) :: list(atom()) | nil
  def get_primary_keys(query) do
    %{source: {_table, model}} = query.from

    if model do
      model.__schema__(:primary_key)
    else
      nil
    end
  end

  @doc """
  Converts a filterable option list to a map format if it's a keyword list.

  This function checks if the input is a keyword list and converts it to a map.
  If the input is not a list or not a keyword list, it returns the input unchanged.

  ## Parameters

  - `list` - Input that may be a keyword list, regular list, or other type

  ## Examples

      iex> FatEcto.SharedHelper.filterable_opt_to_map([name: ["$LIKE"], age: ["$GT"]])
      %{"name" => ["$LIKE"], "age" => ["$GT"]}

      iex> FatEcto.SharedHelper.filterable_opt_to_map(%{"name" => ["$LIKE"]})
      %{"name" => ["$LIKE"]}
  """
  @spec filterable_opt_to_map(maybe_improper_list() | any()) :: maybe_improper_list() | map()
  def filterable_opt_to_map(list) when is_list(list) do
    if Keyword.keyword?(list) do
      keyword_list_to_map_with_uppercase_operators(list)
    else
      list
      |> Enum.map(fn k -> {Atom.to_string(k), "*"} end)
      |> Map.new()
    end
  end

  def filterable_opt_to_map(input), do: input

  @doc """
  Converts a keyword list to a map with string keys.

  If the input is already a map or not a keyword list, returns it unchanged.

  ## Parameters

  - `list` - A keyword list or map to convert

  ## Examples

      iex> FatEcto.SharedHelper.keyword_list_to_map([name: "John", age: 25])
      %{"name" => "John", "age" => 25}

      iex> FatEcto.SharedHelper.keyword_list_to_map(%{"name" => "John"})
      %{"name" => "John"}
  """
  @spec keyword_list_to_map(keyword() | map()) :: map()
  def keyword_list_to_map(list) when is_list(list) do
    if Keyword.keyword?(list) do
      list
      |> Enum.map(fn {k, v} -> {Atom.to_string(k), v} end)
      |> Map.new()
    else
      list
    end
  end

  def keyword_list_to_map(input), do: input

  @doc """
  Converts a keyword list to a map with string keys and normalizes operator values to uppercase.

  This function is specifically designed for processing filterable options where
  operator values need to be normalized to uppercase format.

  ## Parameters

  - `list` - A keyword list or map to convert

  ## Examples

      iex> FatEcto.SharedHelper.keyword_list_to_map_with_uppercase_operators([name: ["like"], age: ["gt"]])
      %{"name" => ["LIKE"], "age" => ["GT"]}
  """
  @spec keyword_list_to_map_with_uppercase_operators(keyword() | map()) :: map()
  def keyword_list_to_map_with_uppercase_operators(list) when is_list(list) do
    if Keyword.keyword?(list) do
      list
      |> Enum.map(fn {k, v} -> {Atom.to_string(k), normalize_operators(v)} end)
      |> Map.new()
    else
      list
    end
  end

  def keyword_list_to_map_with_uppercase_operators(input), do: input

  # Normalizes operator values to uppercase
  defp normalize_operators(operators) when is_list(operators) do
    Enum.map(operators, &String.upcase/1)
  end

  defp normalize_operators(operator) when is_binary(operator) do
    String.upcase(operator)
  end

  defp normalize_operators(operator), do: operator

  @doc """
  Parses an integer from a string or returns the integer if already an integer.

  Returns the parsed integer on success or `nil` on failure.
  """
  @spec parse_integer!(any()) :: integer() | nil
  def parse_integer!(int_str) do
    cond do
      is_integer(int_str) -> int_str
      is_binary(int_str) -> do_parse_integer(int_str)
      true -> nil
    end
  end

  # Helper function to parse an integer from a string
  defp do_parse_integer(int_str) do
    case Integer.parse(int_str) do
      {integer, _} -> integer
      :error -> nil
    end
  end

  @doc """
  Converts various date/datetime inputs to an Elixir Date struct.

  Accepts:
  - String date (e.g., "2023-12-25")
  - String datetime (e.g., "2023-12-25T10:30:00Z", "2023-12-25 10:30:00")
  - Elixir Date struct
  - Elixir DateTime struct

  Returns `{:ok, date}` on success or `{:error, reason}` on failure.

  ## Examples
      iex> FatEcto.SharedHelper.to_date("2023-12-25")
      {:ok, ~D[2023-12-25]}

      iex> FatEcto.SharedHelper.to_date("2023-12-25T10:30:00Z")
      {:ok, ~D[2023-12-25]}

      iex> FatEcto.SharedHelper.to_date(~D[2023-12-25])
      {:ok, ~D[2023-12-25]}

      iex> FatEcto.SharedHelper.to_date(~U[2023-12-25 10:30:00Z])
      {:ok, ~D[2023-12-25]}
  """
  @spec to_date(String.t() | Date.t() | DateTime.t()) :: {:ok, Date.t()} | {:error, atom()}
  def to_date(%Date{} = date), do: {:ok, date}

  def to_date(%DateTime{} = datetime), do: {:ok, DateTime.to_date(datetime)}

  def to_date(date_string) when is_binary(date_string) do
    cond do
      # Try parsing as ISO date first (YYYY-MM-DD)
      String.match?(date_string, ~r/^\d{4}-\d{2}-\d{2}$/) ->
        Date.from_iso8601(date_string)

      # Try parsing as datetime with T separator (ISO 8601)
      String.contains?(date_string, "T") ->
        case DateTime.from_iso8601(date_string) do
          {:ok, datetime, _offset} -> {:ok, DateTime.to_date(datetime)}
          {:error, reason} -> {:error, reason}
        end

      # Try parsing as datetime with space separator (YYYY-MM-DD HH:MM:SS)
      String.match?(date_string, ~r/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/) ->
        case NaiveDateTime.from_iso8601(date_string) do
          {:ok, naive_datetime} -> {:ok, NaiveDateTime.to_date(naive_datetime)}
          {:error, reason} -> {:error, reason}
        end

      # Try parsing as date with various separators (YYYY/MM/DD, YYYY.MM.DD)
      String.match?(date_string, ~r/^\d{4}[\/\.]\d{2}[\/\.]\d{2}$/) ->
        normalized_date = String.replace(date_string, ~r/[\/\.]/, "-")
        Date.from_iso8601(normalized_date)

      # Default fallback - try to parse as ISO date
      true ->
        Date.from_iso8601(date_string)
    end
  end

  def to_date(_), do: {:error, :invalid_input}

  @doc """
  Converts various date/datetime inputs to an Elixir Date struct.

  Similar to `to_date/1` but raises an exception on failure.

  ## Examples
      iex> FatEcto.SharedHelper.to_date!("2023-12-25")
      ~D[2023-12-25]

      iex> FatEcto.SharedHelper.to_date!(~U[2023-12-25 10:30:00Z])
      ~D[2023-12-25]
  """
  @spec to_date!(String.t() | Date.t() | DateTime.t()) :: Date.t()
  def to_date!(input) do
    case to_date(input) do
      {:ok, date} -> date
      {:error, reason} -> raise ArgumentError, "Invalid date input: #{inspect(input)}, reason: #{reason}"
    end
  end

  # ============================================
  # Join Filter Helpers
  # ============================================

  @doc """
  Checks if a filterable entry is a join filter (nested keyword list).

  A join filter is detected when the value is a keyword list (nested fields)
  rather than a list of operator strings.

  ## Examples

      iex> FatEcto.SharedHelper.join_filter?({:title, ["$ILIKE"]})
      false

      iex> FatEcto.SharedHelper.join_filter?({:classifications, [subject_id: ["$EQUAL"]]})
      true

      iex> FatEcto.SharedHelper.join_filter?({:name, "*"})
      false
  """
  @spec join_filter?({atom(), any()}) :: boolean()
  def join_filter?({_field, value}) when is_list(value) do
    # Check if it's a keyword list AND the first element's value is also a list
    # This distinguishes [subject_id: ["$EQUAL"]] from ["$EQUAL", "$IN"]
    Keyword.keyword?(value) and length(value) > 0 and
      match?([{_, nested_val} | _] when is_list(nested_val), value)
  end

  def join_filter?(_), do: false

  @doc """
  Flattens a filterable config into a map of field => operators.

  Direct filters: {field, [operators]} -> {"field" => [uppercase_ops]}
  Join filters: {assoc, [nested]} -> each nested field gets "*" wildcard

  This is the main function to convert filterable option to a field map.

  ## Examples

      iex> FatEcto.SharedHelper.flatten_filterable_to_map([title: ["$ilike"], classifications: [subject_id: ["$EQUAL"]]])
      %{"title" => ["$ILIKE"], "subject_id" => "*"}

      iex> FatEcto.SharedHelper.flatten_filterable_to_map([name: ["$equal"], age: ["$gt"]])
      %{"name" => ["$EQUAL"], "age" => ["$GT"]}
  """
  @spec flatten_filterable_to_map(keyword() | list()) :: map()
  def flatten_filterable_to_map(filterable) when is_list(filterable) do
    if Keyword.keyword?(filterable) do
      filterable
      |> Enum.flat_map(&flatten_filterable_entry/1)
      |> Map.new()
    else
      # Plain list of atoms (overrideable style)
      Map.new(filterable, fn k -> {Atom.to_string(k), "*"} end)
    end
  end

  def flatten_filterable_to_map(_), do: %{}

  defp flatten_filterable_entry(entry) do
    if join_filter?(entry) do
      # Join filter: extract nested fields with "*" wildcard
      {_assoc, fields} = entry
      Enum.map(fields, fn {nested_field, _ops} -> {to_string(nested_field), "*"} end)
    else
      # Direct filter: normalize operators to uppercase
      {field, operators} = entry
      [{to_string(field), safe_normalize_operators(operators)}]
    end
  end

  # Safely normalizes operators - only processes lists of strings
  defp safe_normalize_operators(operators) when is_list(operators) do
    if Enum.all?(operators, &is_binary/1) do
      Enum.map(operators, &String.upcase/1)
    else
      # Not a list of strings, return as-is
      operators
    end
  end

  defp safe_normalize_operators(operator) when is_binary(operator), do: String.upcase(operator)
  defp safe_normalize_operators(other), do: other

  @doc """
  Separates filterable into direct filters and join filters.

  Direct filters have a list of operator strings as values.
  Join filters have a nested keyword list as values.

  ## Examples

      iex> FatEcto.SharedHelper.separate_filterables([title: ["$ILIKE"], classifications: [subject_id: ["$EQUAL"]]])
      {[title: ["$ILIKE"]], [classifications: [subject_id: ["$EQUAL"]]]}

      iex> FatEcto.SharedHelper.separate_filterables([name: ["$EQUAL"], age: ["$GT"]])
      {[name: ["$EQUAL"], age: ["$GT"]], []}
  """
  @spec separate_filterables(keyword() | any()) :: {keyword(), keyword()}
  def separate_filterables(filterable) when is_list(filterable) do
    Enum.split_with(filterable, fn entry -> not join_filter?(entry) end)
  end

  def separate_filterables(filterable), do: {filterable, []}

  @doc """
  Extracts field names from join filters as strings for overrideable list.

  ## Examples

      iex> FatEcto.SharedHelper.extract_join_filter_fields([classifications: [subject_id: ["$EQUAL"], grade_id: ["$EQUAL"]]])
      ["subject_id", "grade_id"]

      iex> FatEcto.SharedHelper.extract_join_filter_fields([])
      []
  """
  @spec extract_join_filter_fields(keyword()) :: [String.t()]
  def extract_join_filter_fields(join_filters) when is_list(join_filters) do
    Enum.flat_map(join_filters, fn {_assoc, fields} ->
      Enum.map(fields, fn {field, _operators} -> to_string(field) end)
    end)
  end

  def extract_join_filter_fields(_), do: []

  @doc """
  Builds a map of field_name => binding for join filters.

  This map is used by Builder to determine which fields should use
  JoinOperatorApplier instead of the standard OperatorApplier.

  ## Examples

      iex> FatEcto.SharedHelper.build_join_filters_map([classifications: [subject_id: ["$EQUAL"], grade_id: ["$EQUAL"]]])
      %{"subject_id" => :classifications, "grade_id" => :classifications}

      iex> FatEcto.SharedHelper.build_join_filters_map([])
      %{}
  """
  @spec build_join_filters_map(keyword()) :: map()
  def build_join_filters_map(join_filters) when is_list(join_filters) do
    join_filters
    |> Enum.flat_map(fn {assoc, fields} ->
      Enum.map(fields, fn {field, _operators} -> {to_string(field), assoc} end)
    end)
    |> Map.new()
  end

  def build_join_filters_map(_), do: %{}
end
