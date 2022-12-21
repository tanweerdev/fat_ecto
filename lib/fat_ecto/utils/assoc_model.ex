defmodule FatEcto.AssocModel do
  def has_and_many_to_many(model) do
    Enum.filter(all(model), fn association ->
      case association do
        %Ecto.Association.Has{} -> true
        %Ecto.Association.ManyToMany{} -> true
        _ -> false
      end
    end)
  end

  def has_only(model) do
    Enum.filter(all(model), fn association ->
      case association do
        %Ecto.Association.Has{} -> true
        _ -> false
      end
    end)
  end

  def all(model) do
    Enum.reduce(model.__schema__(:associations), [], fn relation_name, acc ->
      acc ++ [model.__schema__(:association, relation_name)]
    end)
  end
end

# Example of each association type
# %Ecto.Association.Has{
#   cardinality: :many,
#   defaults: [],
#   field: :users,
#   on_cast: nil,
#   on_delete: :nothing,
#   on_replace: :raise,
#   owner: HaiData.Customer,
#   owner_key: :id,
#   queryable: HaiData.User,
#   related: HaiData.User,
#   related_key: :customer_id,
#   relationship: :child,
#   unique: true,
#   where: []
# }

# %Ecto.Association.BelongsTo{
#   cardinality: :one,
#   defaults: [],
#   field: :business_contact,
#   on_cast: nil,
#   on_replace: :raise,
#   owner: HaiData.Customer,
#   owner_key: :business_contact_id,
#   queryable: HaiData.Contact,
#   related: HaiData.Contact,
#   related_key: :id,
#   relationship: :parent,
#   unique: true,
#   where: []
# }

# %Ecto.Association.ManyToMany{
#   cardinality: :many,
#   defaults: [],
#   field: :users,
#   join_keys: [facility_id: :id, user_id: :id],
#   join_through: "users_facilities",
#   on_cast: nil,
#   on_delete: :nothing,
#   on_replace: :raise,
#   owner: HaiData.Facility,
#   owner_key: :id,
#   queryable: HaiData.User,
#   related: HaiData.User,
#   relationship: :child,
#   unique: false,
#   where: []
# }
