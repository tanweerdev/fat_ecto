defmodule FatEcto.FatQuery.FatNotDynamics do

  import Ecto.Query
  alias FatEcto.FatHelper

  @doc """
  Builds a dynamic query where field is not nil.
  ## => not_nil
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "location"]
      ...>    },
      ...>   "$where" => %{
      ...>      "$not_null" => ["email"]
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: not(is_nil(f0.email)) and ^true, select: map(f0, [:name, :location])>
  """
  @spec not_is_nil_dynamic(any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_is_nil_dynamic(key, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [c],
          not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
        )
      else
        dynamic(
          [c],
          not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not greater than given value.
  ## => not_gt_dynamics
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `value`     - Pass a value of the field.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "location"]
      ...>    },
      ...>   "$where" => %{
      ...>      "$not" => %{
      ...>        "floor" => %{"$gt" => 3}
      ...>      }
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.floor < ^3 or ^true, select: map(f0, [:name, :location])>

  """

  @spec not_gt_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_gt_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) < ^value and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) < ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) < ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) < ^value or ^dynamics
          )
        end
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not greater than and equal to given value.
  ## => not_gte_dynamics
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `value`     - Pass a value of the field.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "location"]
      ...>    },
      ...>   "$where" => %{
      ...>      "$not" => %{
      ...>        "floor" => %{"$gte" => 3}
      ...>      }
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.floor < ^3 or ^true, select: map(f0, [:name, :location])>
  """

  @spec not_gte_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_gte_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) < ^value and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) < ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) < ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) < ^value or ^dynamics
          )
        end
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not less than given value.
  ## => not_lt_dynamics
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `value`     - Pass a value of the field.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "location"]
      ...>    },
      ...>   "$where" => %{
      ...>      "$not" => %{
      ...>        "floor" => %{"$lt" => 2}
      ...>      }
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.floor > ^2 or ^true, select: map(f0, [:name, :location])>
  """

  @spec not_lte_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_lte_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [c],
            field(c, ^FatHelper.string_to_existing_atom(key)) > ^value and ^dynamics
          )
        else
          dynamic(
            [c],
            field(c, ^FatHelper.string_to_existing_atom(key)) > ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) > ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) > ^value or ^dynamics
          )
        end
      end
    end
  end

  @doc """
  Builds a dynamic query where field is not less than and equal to given value.
  ## => not_lte_dynamics
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `value`     - Pass a value of the field.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "location"]
      ...>    },
      ...>   "$where" => %{
      ...>      "$not" => %{
      ...>        "floor" => %{"$lte" => 2}
      ...>      }
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.floor > ^2 or ^true, select: map(f0, [:name, :location])>
  """

  @spec not_lt_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_lt_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) > ^value and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) > ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) > ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) > ^value or ^dynamics
          )
        end
      end
    end
  end

  @doc """
  Builds a dynamic query where value in the substring doesn't match.
  ## => $not_ilike
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `value`     - Pass a value of the field.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["email", "rating"]
      ...>    },
      ...>   "$where" => %{
      ...>      "designation" => %{"$not_ilike" => "%Surge%"}
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatDoctor, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatDoctor, where: not(ilike(fragment("(?)::TEXT", f0.designation), ^"%Surge%")) and ^true, select: map(f0, [:email, :rating])>


  """

  @spec not_ilike_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_ilike_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not ilike(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          not ilike(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          not ilike(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [q],
          not ilike(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    end
  end


  @doc """
  Builds a dynamic query where value in the substring doesn't match.
  ## => $not_like
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `value`     - Pass a value of the field.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["email", "rating"]
      ...>    },
      ...>   "$where" => %{
      ...>      "email" => %{"$not_like" => "%test%"}
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatDoctor, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatDoctor, where: not(like(fragment("(?)::TEXT", f0.email), ^"%test%")) and ^true, select: map(f0, [:email, :rating])>


  """



  @spec not_like_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_like_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not like(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          not like(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          not like(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [q],
          not like(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    end
  end


  @doc """
  Builds a dynamic query where field is not equal to value.
  ## => not_equal_dynamics
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `value`     - Pass a value of the field.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "rating"]
      ...>    },
      ...>   "$where" => %{
      ...>      "$not" => %{
      ...>         "rating" => %{"$equal" => 2}
      ...>       }
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, select: map(f0, [:name, :rating])>


"""


  @spec not_eq_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_eq_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) != ^value and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) != ^value or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) != ^value and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) != ^value or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where value is not between the provided attributes.
  ## => $not_between
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `values`    - Pass a list of values of the field for minimum and maximum range.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "rating"]
      ...>    },
      ...>   "$where" => %{
      ...>     "total_staff" => %{"$not_between" => [13, 19]}
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: (f0.total_staff < ^13 or f0.total_staff > ^19) and ^true, select: map(f0, [:name, :rating])>


  """


  @spec not_between_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_between_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          (field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
             field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values)) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
            field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          (field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
             field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values)) and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
            field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query where value is not equal and between the provided attributes.
  ## => $not_between_equal
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `values`    - Pass a list of values of the field for minimum and maximum range.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "rating"]
      ...>    },
      ...>   "$where" => %{
      ...>     "total_staff" => %{"$not_between_equal" => [13, 19]}
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: (f0.total_staff <= ^13 or f0.total_staff >= ^19) and ^true, select: map(f0, [:name, :rating])>


  """


  @spec not_between_equal_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_between_equal_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          (field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
             field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values)) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
            field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          (field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
             field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values)) and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
            field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values) or ^dynamics
        )
      end
    end
  end


  @doc """
  Builds a dynamic query where value is not in the the provided list attributes
  ## => $not_in
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `values`    - Pass a list of values of the field that represent range.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "rating"]
      ...>    },
      ...>   "$where" => %{
      ...>     "total_staff" => %{"$not_in" => [3, 9]}
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff not in ^[3, 9] and ^true, select: map(f0, [:name, :rating])>

  """

  @spec not_in_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_in_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) not in ^values and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) not in ^values or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) not in ^values and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) not in ^values or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query that fetch the key and see if it is not contains the value
  ## => not_contains
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `values`    - Pass a list of values of the field.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["email", "rating"]
      ...>    },
      ...>   "$where" => %{
      ...>      "$not" => %{
      ...>        "email" => %{"$contains" => "%test%"}
      ...>      }
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatDoctor, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatDoctor, select: map(f0, [:email, :rating])>

  """

  @spec not_contains_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_contains_dynamic(key, values, dynamics, opts \\ []) do
    # value = Enum.join(value, " ")
    # where: fragment("? @> ?::jsonb", c.exclusions, ^[dish_id])

    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          not fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          not fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [q],
          not fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    end
  end

  @doc """
  Builds a dynamic query that fetch the key and see if it contains not any the value
  ## => not_contains_any
  ### Parameters

    - `key`       - Pass a key that is an field name of the schema.
    - `values`    - Pass a list of values of the field.
    - `dynamics`  - Pass dynamics to add queries dynamically.
    - `opts`      - Pass options related to query bindings.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["email", "rating"]
      ...>    },
      ...>   "$where" => %{
      ...>      "$not" => %{
      ...>        "email" => %{"$contains_any" => "%test%"}
      ...>      }
      ...>    }
      ...>  }
      iex> #{__MODULE__}.build(FatEcto.FatDoctor, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatDoctor, select: map(f0, [:email, :rating])>


  """


  @spec not_contains_any_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def not_contains_any_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          not fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          not fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          not fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [q],
          not fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    end
  end
end
