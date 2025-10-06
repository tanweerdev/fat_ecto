defmodule FatEcto.Params.Validator do
  @moduledoc """
  Provides validation for query parameters including filtering, sorting, and pagination.

  This module helps validate parameters before they are used in query building,
  providing early error detection and clearer error messages.

  ## Validation Behavior Options

  You can configure how the validator handles unconfigured fields and operators:

  - `:raise` (default) - Raises an error when encountering unconfigured fields/operators
  - `:warn` - Logs a warning and continues processing
  - `:ignore` - Silently skips unconfigured fields/operators

  ## Example Usage

      iex> params = %{"limit" => 10, "skip" => 0}
      iex> FatEcto.Params.Validator.validate_pagination(params, max_limit: 100)
      {:ok, %{limit: 10, skip: 0}}

      iex> params = %{"limit" => 1000, "skip" => 0}
      iex> FatEcto.Params.Validator.validate_pagination(params, max_limit: 100)
      {:error, "limit exceeds maximum allowed value of 100"}

  ## Validation Options Examples

  ### Default Behavior (`:raise`)

      # Raises error for unconfigured fields
      opts = [filterable_fields: %{"name" => ["$ILIKE"]}]
      validate_filters(%{"email" => %{"$EQUAL" => "test@example.com"}}, opts)
      # Returns: {:error, "field 'email' is not in the list of filterable fields"}

  ### Ignore Unconfigured Fields (`:ignore`)

      # Silently ignores unconfigured fields
      opts = [
        filterable_fields: %{"name" => ["$ILIKE"]},
        unconfigured_fields: :ignore
      ]
      validate_filters(%{"name" => %{"$ILIKE" => "John"}, "email" => %{"$EQUAL" => "test@example.com"}}, opts)
      # Returns: {:ok, %{"name" => %{"$ILIKE" => "John"}, "email" => %{"$EQUAL" => "test@example.com"}}}

  ### Warn on Unconfigured Operators (`:warn`)

      # Logs warning but continues processing
      opts = [
        filterable_fields: %{"name" => ["$ILIKE"]},
        unconfigured_operators: :warn
      ]
      validate_filters(%{"name" => %{"$GT" => "John"}}, opts)
      # Logs warning and returns: {:ok, %{"name" => %{"$GT" => "John"}}}

  ### Combined Options

      # Apply different behaviors for fields and operators
      opts = [
        filterable_fields: %{"name" => ["$ILIKE"]},
        sortable_fields: %{"name" => ["$ASC"]},
        unconfigured_fields: :ignore,      # Ignore unknown fields
        unconfigured_operators: :warn,      # Warn on unknown operators
        max_limit: 100
      ]
      validate(%{
        "filter" => %{"name" => %{"$GT" => "John"}, "email" => %{"$EQUAL" => "test"}},
        "sort" => %{"name" => "$DESC", "age" => "$ASC"}
      }, opts)
      # Ignores email field, warns about $GT and $DESC operators
  """

  alias FatEcto.SharedHelper
  require Logger

  @type validation_error :: String.t()
  @type validation_result :: {:ok, map()} | {:error, validation_error()}

  @doc """
  Validates pagination parameters.

  ## Parameters
  - `params`: Map or keyword list containing pagination parameters
  - `opts`: Options including `:max_limit` and `:default_limit`

  ## Returns
  - `{:ok, validated_params}` on success
  - `{:error, reason}` on validation failure

  ## Examples

      iex> FatEcto.Params.Validator.validate_pagination(%{"limit" => 10}, max_limit: 100)
      {:ok, %{limit: 10, skip: 0}}

      iex> FatEcto.Params.Validator.validate_pagination(%{"limit" => -1}, max_limit: 100)
      {:error, "limit must be a positive integer"}
  """
  @spec validate_pagination(map() | keyword(), keyword()) :: validation_result()
  def validate_pagination(params, opts \\ []) when is_map(params) or is_list(params) do
    params = if is_list(params), do: Map.new(params), else: params
    max_limit = Keyword.get(opts, :max_limit, 100)
    default_limit = Keyword.get(opts, :default_limit, 20)

    with {:ok, limit} <- validate_limit(params, max_limit, default_limit),
         {:ok, skip} <- validate_skip(params) do
      {:ok, %{limit: limit, skip: skip}}
    end
  end

  @doc """
  Validates filter parameters against allowed filterable fields and operators.

  ## Parameters
  - `params`: Filter parameters map
  - `opts`: Validation options
    - `:filterable_fields` - Map of allowed fields and their operators
    - `:unconfigured_fields` - How to handle unconfigured fields (:raise, :warn, :ignore) (default: :raise)
    - `:unconfigured_operators` - How to handle unconfigured operators (:raise, :warn, :ignore) (default: :raise)

  ## Returns
  - `{:ok, validated_params}` on success
  - `{:error, reason}` on validation failure

  ## Examples

      iex> opts = [filterable_fields: %{"name" => ["$ILIKE"], "age" => ["$GT", "$LT"]}]
      iex> params = %{"name" => %{"$ILIKE" => "%John%"}}
      iex> FatEcto.Params.Validator.validate_filters(params, opts)
      {:ok, %{"name" => %{"$ILIKE" => "%John%"}}}

      iex> opts = [filterable_fields: %{"name" => ["$ILIKE"]}]
      iex> params = %{"email" => %{"$EQUAL" => "test@example.com"}}
      iex> FatEcto.Params.Validator.validate_filters(params, opts)
      {:error, "field 'email' is not in the list of filterable fields"}

      iex> opts = [filterable_fields: %{"name" => ["$ILIKE"]}, unconfigured_fields: :ignore]
      iex> params = %{"email" => %{"$EQUAL" => "test@example.com"}}
      iex> FatEcto.Params.Validator.validate_filters(params, opts)
      {:ok, %{"email" => %{"$EQUAL" => "test@example.com"}}}
  """
  @spec validate_filters(map(), keyword() | map()) :: validation_result()
  def validate_filters(params, opts) when is_map(params) do
    opts = normalize_opts(opts)
    filterable_fields = Keyword.get(opts, :filterable_fields, %{})
    unconfigured_fields = Keyword.get(opts, :unconfigured_fields, :raise)
    unconfigured_operators = Keyword.get(opts, :unconfigured_operators, :raise)

    validation_opts = [
      unconfigured_fields: unconfigured_fields,
      unconfigured_operators: unconfigured_operators
    ]

    case do_validate_filters(params, filterable_fields, [], validation_opts) do
      {:ok, _} -> {:ok, params}
      {:error, errors} -> {:error, Enum.join(errors, "; ")}
    end
  end

  @doc """
  Validates sort parameters against allowed sortable fields.

  ## Parameters
  - `params`: Sort parameters map
  - `opts`: Validation options
    - `:sortable_fields` - Map of allowed sortable fields and their operators
    - `:unconfigured_fields` - How to handle unconfigured fields (:raise, :warn, :ignore) (default: :raise)
    - `:unconfigured_operators` - How to handle unconfigured operators (:raise, :warn, :ignore) (default: :raise)

  ## Returns
  - `{:ok, validated_params}` on success
  - `{:error, reason}` on validation failure

  ## Examples

      iex> opts = [sortable_fields: %{"name" => ["$ASC", "$DESC"], "age" => "*"}]
      iex> params = %{"name" => "$DESC"}
      iex> FatEcto.Params.Validator.validate_sort(params, opts)
      {:ok, %{"name" => "$DESC"}}

      iex> opts = [sortable_fields: %{"name" => ["$ASC"]}]
      iex> params = %{"name" => "$DESC"}
      iex> FatEcto.Params.Validator.validate_sort(params, opts)
      {:error, "operator '$DESC' is not allowed for field 'name'"}

      iex> opts = [sortable_fields: %{"name" => ["$ASC"]}, unconfigured_operators: :ignore]
      iex> params = %{"name" => "$DESC"}
      iex> FatEcto.Params.Validator.validate_sort(params, opts)
      {:ok, %{"name" => "$DESC"}}
  """
  @spec validate_sort(map(), keyword() | map()) :: validation_result()
  def validate_sort(params, opts) when is_map(params) do
    opts = normalize_opts(opts)
    sortable_fields = Keyword.get(opts, :sortable_fields, %{})
    unconfigured_fields = Keyword.get(opts, :unconfigured_fields, :raise)
    unconfigured_operators = Keyword.get(opts, :unconfigured_operators, :raise)

    validation_opts = [
      unconfigured_fields: unconfigured_fields,
      unconfigured_operators: unconfigured_operators
    ]

    case do_validate_sort(params, sortable_fields, [], validation_opts) do
      {:ok, _} -> {:ok, params}
      {:error, errors} -> {:error, Enum.join(errors, "; ")}
    end
  end

  @doc """
  Validates all query parameters (pagination, filtering, and sorting).

  ## Parameters
  - `params`: Map containing all query parameters
  - `opts`: Options including:
    - `:filterable_fields` - Map of allowed filterable fields
    - `:sortable_fields` - Map of allowed sortable fields
    - `:max_limit` - Maximum pagination limit
    - `:default_limit` - Default pagination limit

  ## Returns
  - `{:ok, validated_params}` on success
  - `{:error, errors}` on validation failure

  ## Examples

      iex> params = %{
      ...>   "filter" => %{"name" => %{"$ILIKE" => "%John%"}},
      ...>   "sort" => %{"name" => "$ASC"},
      ...>   "limit" => 10
      ...> }
      iex> opts = [
      ...>   filterable_fields: %{"name" => ["$ILIKE"]},
      ...>   sortable_fields: %{"name" => ["$ASC"]},
      ...>   max_limit: 100
      ...> ]
      iex> FatEcto.Params.Validator.validate(params, opts)
      {:ok, %{filter: ..., sort: ..., pagination: ...}}
  """
  @spec validate(map(), keyword()) :: validation_result()
  def validate(params, opts \\ []) when is_map(params) do
    with {:ok, pagination_result, errors1} <- validate_pagination_if_present(params, opts, []),
         {:ok, filter_result, errors2} <- validate_filters_if_present(params, opts, errors1),
         {:ok, sort_result, errors3} <- validate_sort_if_present(params, opts, errors2) do
      build_validation_result(pagination_result, filter_result, sort_result, errors3)
    end
  end

  defp validate_pagination_if_present(params, opts, errors) do
    case Map.get(params, "limit") || Map.get(params, "skip") do
      nil ->
        {:ok, nil, errors}

      _ ->
        case validate_pagination(params, opts) do
          {:ok, pagination} -> {:ok, pagination, errors}
          {:error, error} -> {:ok, nil, ["Pagination: #{error}" | errors]}
        end
    end
  end

  defp validate_filters_if_present(params, opts, errors) do
    case Map.get(params, "filter") do
      nil ->
        {:ok, nil, errors}

      filter_params ->
        case validate_filters(filter_params, opts) do
          {:ok, filters} -> {:ok, filters, errors}
          {:error, error} -> {:ok, nil, ["Filters: #{error}" | errors]}
        end
    end
  end

  defp validate_sort_if_present(params, opts, errors) do
    case Map.get(params, "sort") do
      nil ->
        {:ok, nil, errors}

      sort_params ->
        case validate_sort(sort_params, opts) do
          {:ok, sort} -> {:ok, sort, errors}
          {:error, error} -> {:ok, nil, ["Sort: #{error}" | errors]}
        end
    end
  end

  defp build_validation_result(pagination_result, filter_result, sort_result, errors) do
    case errors do
      [] ->
        result =
          %{}
          |> maybe_put(:pagination, pagination_result)
          |> maybe_put(:filter, filter_result)
          |> maybe_put(:sort, sort_result)

        {:ok, result}

      errors ->
        error_message = errors |> Enum.reverse() |> Enum.join("; ")
        {:error, error_message}
    end
  end

  # Private Functions

  defp validate_limit(params, max_limit, default_limit) do
    case Map.get(params, "limit") do
      nil ->
        {:ok, default_limit}

      limit when is_integer(limit) ->
        cond do
          limit < 0 -> {:error, "limit must be a positive integer"}
          limit > max_limit -> {:error, "limit exceeds maximum allowed value of #{max_limit}"}
          true -> {:ok, limit}
        end

      limit when is_binary(limit) ->
        case SharedHelper.parse_integer!(limit) do
          nil -> {:error, "limit must be a valid integer"}
          int_limit -> validate_limit(%{"limit" => int_limit}, max_limit, default_limit)
        end

      _ ->
        {:error, "limit must be an integer"}
    end
  end

  defp validate_skip(params) do
    case Map.get(params, "skip") do
      nil ->
        {:ok, 0}

      skip when is_integer(skip) ->
        if skip < 0 do
          {:error, "skip must be a non-negative integer"}
        else
          {:ok, skip}
        end

      skip when is_binary(skip) ->
        case SharedHelper.parse_integer!(skip) do
          nil -> {:error, "skip must be a valid integer"}
          int_skip -> validate_skip(%{"skip" => int_skip})
        end

      _ ->
        {:error, "skip must be an integer"}
    end
  end

  defp do_validate_filters(params, filterable_fields, errors, validation_opts) do
    unconfigured_fields_behavior = Keyword.get(validation_opts, :unconfigured_fields, :raise)
    unconfigured_operators_behavior = Keyword.get(validation_opts, :unconfigured_operators, :raise)

    result =
      Enum.reduce(params, {:ok, errors}, fn {field, value}, {:ok, acc_errors} ->
        # Handle $OR and $AND
        if field in ["$OR", "$AND"] do
          case validate_logical_filters(value, filterable_fields, validation_opts) do
            :ok -> {:ok, acc_errors}
            {:error, error} -> {:ok, [error | acc_errors]}
          end
        else
          # Validate regular field
          cond do
            not Map.has_key?(filterable_fields, field) ->
              handle_validation_error(
                "field '#{field}' is not in the list of filterable fields",
                unconfigured_fields_behavior,
                acc_errors
              )

            is_map(value) ->
              validate_field_operators(
                field,
                value,
                filterable_fields,
                acc_errors,
                unconfigured_operators_behavior
              )

            true ->
              {:ok, acc_errors}
          end
        end
      end)

    case result do
      {:ok, []} -> {:ok, params}
      {:ok, errors} -> {:error, Enum.reverse(errors)}
    end
  end

  defp validate_logical_filters(conditions, filterable_fields, validation_opts) when is_list(conditions) do
    Enum.reduce_while(conditions, :ok, fn condition, :ok ->
      case do_validate_filters(condition, filterable_fields, [], validation_opts) do
        {:ok, _} -> {:cont, :ok}
        {:error, errors} -> {:halt, {:error, Enum.join(errors, "; ")}}
      end
    end)
  end

  defp validate_logical_filters(condition, filterable_fields, validation_opts) when is_map(condition) do
    case do_validate_filters(condition, filterable_fields, [], validation_opts) do
      {:ok, _} -> :ok
      {:error, errors} -> {:error, Enum.join(errors, "; ")}
    end
  end

  defp validate_field_operators(
         field,
         operators_map,
         filterable_fields,
         errors,
         unconfigured_operators_behavior
       ) do
    allowed_operators = Map.get(filterable_fields, field)

    operator_errors =
      Enum.reduce(operators_map, [], fn {operator, _value}, acc ->
        normalized_operator = String.upcase(operator)

        if operator_allowed?(normalized_operator, allowed_operators) do
          acc
        else
          error_msg = "operator '#{operator}' is not allowed for field '#{field}'"

          case unconfigured_operators_behavior do
            :raise ->
              [error_msg | acc]

            :warn ->
              Logger.warning("Validation warning: #{error_msg}")
              acc

            :ignore ->
              acc
          end
        end
      end)

    {:ok, operator_errors ++ errors}
  end

  defp operator_allowed?(operator, allowed_operators) when is_list(allowed_operators) do
    operator in allowed_operators
  end

  defp operator_allowed?(_operator, "*"), do: true
  defp operator_allowed?(_operator, _), do: false

  defp do_validate_sort(params, sortable_fields, errors, validation_opts) do
    unconfigured_fields_behavior = Keyword.get(validation_opts, :unconfigured_fields, :raise)
    unconfigured_operators_behavior = Keyword.get(validation_opts, :unconfigured_operators, :raise)

    result =
      Enum.reduce(params, {:ok, errors}, fn {field, operator}, {:ok, acc_errors} ->
        cond do
          not Map.has_key?(sortable_fields, field) ->
            handle_validation_error(
              "field '#{field}' is not in the list of sortable fields",
              unconfigured_fields_behavior,
              acc_errors
            )

          not sort_operator_allowed?(operator, Map.get(sortable_fields, field)) ->
            handle_validation_error(
              "operator '#{operator}' is not allowed for field '#{field}' in sort",
              unconfigured_operators_behavior,
              acc_errors
            )

          true ->
            {:ok, acc_errors}
        end
      end)

    case result do
      {:ok, []} -> {:ok, params}
      {:ok, errors} -> {:error, Enum.reverse(errors)}
    end
  end

  defp sort_operator_allowed?(operator, allowed_operators) when is_list(allowed_operators) do
    String.upcase(operator) in allowed_operators
  end

  defp sort_operator_allowed?(_operator, "*"), do: true
  defp sort_operator_allowed?(_operator, _), do: false

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp normalize_opts(opts) when is_map(opts), do: Map.to_list(opts)
  defp normalize_opts(opts) when is_list(opts), do: opts

  defp handle_validation_error(error_msg, behavior, acc_errors) do
    case behavior do
      :raise ->
        {:ok, [error_msg | acc_errors]}

      :warn ->
        Logger.warning("Validation warning: #{error_msg}")
        {:ok, acc_errors}

      :ignore ->
        {:ok, acc_errors}
    end
  end
end
