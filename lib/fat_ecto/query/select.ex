defmodule FatEcto.FatQuery.FatSelect do
  # TODO: Add docs and examples for ex_doc
  alias FatEcto.FatHelper
  import Ecto.Query
  # TODO: Add docs and examples for ex_doc
  @doc """
  Build a  `select query` depending on the params.
  ## Parameters

    - `queryable`- Schema name that represents your database model.
    - `query_opts` - include query options as a map
  ## Examples
      iex> query_opts = %{
      ...>  "$select" => %{
      ...>    "$fields" => ["name", "location", "rating"],
      ...>    "fat_rooms" => ["beds", "capacity"]
      ...>  },
      ...>  "$order" => %{"id" => "$desc"},
      ...>  "$where" => %{"rating" => 4},
      ...> "$include" => %{
      ...>    "fat_doctors" => %{
      ...>      "$include" => ["fat_patients"],
      ...>      "$where" => %{"name" => "ham"},
      ...>      "$order" => %{"id" => "$desc"}
      ...>    }
      ...>  }
      ...> }
      iex> #{FatEcto.FatQuery}.build(FatEcto.FatHospital, query_opts)
      #Ecto.Query<from f0 in FatEcto.FatHospital, join: f1 in assoc(f0, :fat_doctors), where: f0.rating == ^4 and ^true, order_by: [desc: f0.id], select: map(f0, [:name, :location, :rating, :id, {:fat_rooms, [:beds, :capacity]}]), preload: [fat_doctors: #Ecto.Query<from f in FatEcto.FatDoctor, where: f.name == ^"ham" and ^true, order_by: [desc: f.id], limit: ^10, offset: ^0, preload: [:fat_patients]>]>




  ## Options

    - `$include`- Include the assoication `doctors`.
    - `$include: :fat_patients`- Include the assoication `patients`. Which has association with `doctors`.
    - `$select`- Select the fields from `hospital` and `rooms`.
    - `$where`- Added the where attribute in the query.
    - `$order`- Sort the result based on the order attribute.


  """

  def build_select(queryable, nil, _model) do
    queryable
  end

  def build_select(queryable, select_params, model) do
    case select_params do
      # TODO: Add docs and examples of ex_doc for this case here
      select when is_map(select) ->
        # TODO: Add docs and examples of ex_doc for this case here
        fields =
          Enum.reduce(select, [], fn {key, value}, fields ->
            if key == "$fields" do
              fields ++ Enum.map(value, &FatHelper.string_to_existing_atom/1)
            else
              # if map contain asso_table and fields
              relation_name = FatHelper.string_to_existing_atom(key)
              assoc_fields = value

              FatHelper.associations(
                model,
                relation_name,
                fields,
                assoc_fields
              )
            end
          end)

        from(q in queryable, select: map(q, ^Enum.uniq(fields)))

      select when is_list(select) ->
        from(
          q in queryable,
          select: map(q, ^Enum.uniq(Enum.map(select, &FatHelper.string_to_existing_atom/1)))
        )
    end
  end
end
