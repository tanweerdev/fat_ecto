defmodule FatEcto.FatQuery.FatDynamics do
  @moduledoc """
  Builds a `where query` using dynamics.

  ### Parameters

    - `queryable`   - Ecto Queryable that represents your schema name, table name or query.
    - `query_opts`  - Where query options as a map.

  ### Examples

      iex> query_opts = %{
      ...>    "$select" => %{
      ...>     "$fields" => ["name", "location", "rating"]
      ...>    },
      ...>   "$where" => %{
      ...>      "name" => "%John%",
      ...>      "location" => nil,
      ...>      "rating" => "$not_null",
      ...>      "total_staff" => %{"$between" => [1, 3]}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff > ^1 and f0.total_staff < ^3 and (not(is_nil(f0.rating)) and (f0.name == ^"%John%" and (is_nil(f0.location) and ^true))), select: map(f0, [:name, :location, :rating])>

  ### Options

    - `$select` - Select the fields from `hospital` and `rooms`.
    - `$where`  - Added the where attribute in the query.
  """

  import Ecto.Query
  alias FatEcto.FatHelper

  @doc """
  ## => nil
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
      ...>      "location" => nil
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: is_nil(f0.location) and ^true, select: map(f0, [:name, :location])>


  ## => $gt
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
      ...>      "floor" => %{"$gt" => 3}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.floor > ^3 and ^true, select: map(f0, [:name, :location])>


  ## => $gte
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
      ...>      "rating" => %{"$gte" => 4}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating >= ^4 and ^true, select: map(f0, [:name, :rating])>

  ## => $lte
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
      ...>      "rating" => %{"$lte" => 2}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating <= ^2 and ^true, select: map(f0, [:name, :rating])>

  ## => $lt
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
      ...>      "rating" => %{"$lt" => 3}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating < ^3 and ^true, select: map(f0, [:name, :rating])>

  ## => $ilike
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
      ...>      "designation" => %{"$ilike" => "%Surge%"}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatDoctor, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatDoctor, where: ilike(fragment("(?)::TEXT", f0.designation), ^"%Surge%") and ^true, select: map(f0, [:email, :rating])>

  ## => $like
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
      ...>      "email" => %{"$like" => "%test%"}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatDoctor, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatDoctor, where: like(fragment("(?)::TEXT", f0.email), ^"%test%") and ^true, select: map(f0, [:email, :rating])>

  ## => $equal
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
      ...>      "$or" => %{
      ...>        "rating" => %{"$equal" => 2}
      ...>      }
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.rating == ^2 or ^true, select: map(f0, [:name, :rating])>

  ## => $between
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
      ...>     "total_staff" => %{"$between" => [13, 19]}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff > ^13 and f0.total_staff < ^19 and ^true, select: map(f0, [:name, :rating])>


  ## => $between_equal
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
      ...>     "total_staff" => %{"$between_equal" => [13, 19]}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff >= ^13 and f0.total_staff <= ^19 and ^true, select: map(f0, [:name, :rating])>

  ## => $in
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
      ...>     "total_staff" => %{"$in" => [3, 9]}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, where: f0.total_staff in ^[3, 9] and ^true, select: map(f0, [:name, :rating])>

  ## => $contains
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
      ...>      "email" => %{"$contains" => "%test%"}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatDoctor, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatDoctor, where: fragment("? @> ?", f0.email, ^"%test%") and ^true, select: map(f0, [:email, :rating])>



  ## => $contains_any
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
      ...>      "email" => %{"$contains_any" => "%test%"}
      ...>    }
      ...>  }
      iex> #{MyApp.Query}.build(FatEcto.FatDoctor, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatDoctor, where: fragment("? && ?", f0.email, ^"%test%") and ^true, select: map(f0, [:email, :rating])>

  """




  @spec is_nil_dynamic(any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def is_nil_dynamic(key, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [c],
          is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
        )
      else
        dynamic(
          [c],
          is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
        )
      end
    end
  end

  @spec gt_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def gt_dynamic(key, value, dynamics, opts \\ []) do
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

  @spec gte_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def gte_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >=
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >=
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >= ^value and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) >= ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >=
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >=
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >= ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) >= ^value or ^dynamics
          )
        end
      end
    end
  end

  @spec lte_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def lte_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <=
              field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [..., c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <=
              field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <= ^value and ^dynamics
          )
        else
          dynamic(
            [c],
            field(c, ^FatHelper.string_to_existing_atom(key)) <= ^value or ^dynamics
          )
        end
      end
    else
      if FatHelper.is_fat_ecto_field?(value) do
        value = String.replace(value, "$", "", global: false)

        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <=
              field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <=
              field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
          )
        end
      else
        if opts[:dynamic_type] == :and do
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <= ^value and ^dynamics
          )
        else
          dynamic(
            [q],
            field(q, ^FatHelper.string_to_existing_atom(key)) <= ^value or ^dynamics
          )
        end
      end
    end
  end

  @spec lt_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def lt_dynamic(key, value, dynamics, opts \\ []) do
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

  @spec ilike_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def ilike_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          ilike(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          ilike(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          ilike(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [q],
          ilike(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    end
  end

  @spec like_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def like_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          like(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          like(
            fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          like(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) and ^dynamics
        )
      else
        dynamic(
          [q],
          like(
            fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
            ^value
          ) or ^dynamics
        )
      end
    end
  end

  @spec eq_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def eq_dynamic(key, value, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) == ^value and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) == ^value or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) == ^value and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) == ^value or ^dynamics
        )
      end
    end
  end

  @spec between_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def between_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
            field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          (field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
             field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values)) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
            field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values) and ^dynamics
        )
      else
        dynamic(
          [q],
          (field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
             field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values)) or ^dynamics
        )
      end
    end
  end

  @spec between_equal_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def between_equal_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
            field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          (field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
             field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values)) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
            field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values) and ^dynamics
        )
      else
        dynamic(
          [q],
          (field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
             field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values)) or ^dynamics
        )
      end
    end
  end

  @spec in_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def in_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) in ^values and ^dynamics
        )
      else
        dynamic(
          [..., c],
          field(c, ^FatHelper.string_to_existing_atom(key)) in ^values or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) in ^values and ^dynamics
        )
      else
        dynamic(
          [q],
          field(q, ^FatHelper.string_to_existing_atom(key)) in ^values or ^dynamics
        )
      end
    end
  end

  @spec contains_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def contains_dynamic(key, values, dynamics, opts \\ []) do
    # value = Enum.join(value, " ")
    # where: fragment("? @> ?::jsonb", c.exclusions, ^[dish_id])

    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [q],
          fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    end
  end

  @spec contains_any_dynamic(any(), any(), any(), nil | keyword() | map()) :: Ecto.Query.DynamicExpr.t()
  def contains_any_dynamic(key, values, dynamics, opts \\ []) do
    if opts[:binding] == :last do
      if opts[:dynamic_type] == :and do
        dynamic(
          [..., c],
          fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [..., c],
          fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    else
      if opts[:dynamic_type] == :and do
        dynamic(
          [q],
          fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and ^dynamics
        )
      else
        dynamic(
          [q],
          fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or ^dynamics
        )
      end
    end
  end

end
