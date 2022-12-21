# defmodule FatEcto.FatQuery.FatDynamics do
#   import Ecto.Query
#   alias FatEcto.FatHelper
#   # TODO: Add docs and examples for ex_doc
#   def is_nil_dynamic(key, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [c],
#           is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
#         )
#       else
#         dynamic(
#           [c],
#           is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
#         )
#       end
#     end
#   end

#   def not_is_nil_dynamic(key, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [c],
#           not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) and ^dynamics
#         )
#       else
#         dynamic(
#           [c],
#           not is_nil(field(c, ^FatHelper.string_to_existing_atom(key))) or ^dynamics
#         )
#       end
#     end
#   end

#   def gt_dynamic(key, value, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if FatHelper.is_fat_ecto_field?(value) do
#         value = String.replace(value, "$", "", global: false)

#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) >
#               field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
#           )
#         else
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) >
#               field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
#           )
#         end
#       else
#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) > ^value and ^dynamics
#           )
#         else
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) > ^value or ^dynamics
#           )
#         end
#       end
#     else
#       if FatHelper.is_fat_ecto_field?(value) do
#         value = String.replace(value, "$", "", global: false)

#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) >
#               field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
#           )
#         else
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) >
#               field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
#           )
#         end
#       else
#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) > ^value and ^dynamics
#           )
#         else
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) > ^value or ^dynamics
#           )
#         end
#       end
#     end
#   end

#   def gte_dynamic(key, value, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if FatHelper.is_fat_ecto_field?(value) do
#         value = String.replace(value, "$", "", global: false)

#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) >=
#               field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
#           )
#         else
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) >=
#               field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
#           )
#         end
#       else
#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) >= ^value and ^dynamics
#           )
#         else
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) >= ^value or ^dynamics
#           )
#         end
#       end
#     else
#       if FatHelper.is_fat_ecto_field?(value) do
#         value = String.replace(value, "$", "", global: false)

#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) >=
#               field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
#           )
#         else
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) >=
#               field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
#           )
#         end
#       else
#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) >= ^value and ^dynamics
#           )
#         else
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) >= ^value or ^dynamics
#           )
#         end
#       end
#     end
#   end

#   def lte_dynamic(key, value, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if FatHelper.is_fat_ecto_field?(value) do
#         value = String.replace(value, "$", "", global: false)

#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) <=
#               field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
#           )
#         else
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) <=
#               field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
#           )
#         end
#       else
#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) <= ^value and ^dynamics
#           )
#         else
#           dynamic(
#             [c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) <= ^value or ^dynamics
#           )
#         end
#       end
#     else
#       if FatHelper.is_fat_ecto_field?(value) do
#         value = String.replace(value, "$", "", global: false)

#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) <=
#               field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
#           )
#         else
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) <=
#               field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
#           )
#         end
#       else
#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) <= ^value and ^dynamics
#           )
#         else
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) <= ^value or ^dynamics
#           )
#         end
#       end
#     end
#   end

#   def lt_dynamic(key, value, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if FatHelper.is_fat_ecto_field?(value) do
#         value = String.replace(value, "$", "", global: false)

#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) <
#               field(c, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
#           )
#         else
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) <
#               field(c, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
#           )
#         end
#       else
#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) < ^value and ^dynamics
#           )
#         else
#           dynamic(
#             [..., c],
#             field(c, ^FatHelper.string_to_existing_atom(key)) < ^value or ^dynamics
#           )
#         end
#       end
#     else
#       if FatHelper.is_fat_ecto_field?(value) do
#         value = String.replace(value, "$", "", global: false)

#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) <
#               field(q, ^FatHelper.string_to_existing_atom(value)) and ^dynamics
#           )
#         else
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) <
#               field(q, ^FatHelper.string_to_existing_atom(value)) or ^dynamics
#           )
#         end
#       else
#         if opts[:dynamic_type] == :and do
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) < ^value and ^dynamics
#           )
#         else
#           dynamic(
#             [q],
#             field(q, ^FatHelper.string_to_existing_atom(key)) < ^value or ^dynamics
#           )
#         end
#       end
#     end
#   end

#   def ilike_dynamic(key, value, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           ilike(
#             fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           ilike(
#             fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           ilike(
#             fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           ilike(
#             fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) or ^dynamics
#         )
#       end
#     end
#   end

#   def not_ilike_dynamic(key, value, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           not ilike(
#             fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           not ilike(
#             fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           not ilike(
#             fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           not ilike(
#             fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) or ^dynamics
#         )
#       end
#     end
#   end

#   def like_dynamic(key, value, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           like(
#             fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           like(
#             fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           like(
#             fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           like(
#             fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) or ^dynamics
#         )
#       end
#     end
#   end

#   def not_like_dynamic(key, value, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           not like(
#             fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           not like(
#             fragment("(?)::TEXT", field(c, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           not like(
#             fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           not like(
#             fragment("(?)::TEXT", field(q, ^FatHelper.string_to_existing_atom(key))),
#             ^value
#           ) or ^dynamics
#         )
#       end
#     end
#   end

#   def eq_dynamic(key, value, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) == ^value and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) == ^value or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) == ^value and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) == ^value or ^dynamics
#         )
#       end
#     end
#   end

#   def not_eq_dynamic(key, value, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) != ^value and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) != ^value or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) != ^value and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) != ^value or ^dynamics
#         )
#       end
#     end
#   end

#   def between_dynamic(key, values, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
#             field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values) and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           (field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
#              field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values)) or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
#             field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values) and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           (field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.min(values) and
#              field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.max(values)) or ^dynamics
#         )
#       end
#     end
#   end

#   def between_equal_dynamic(key, values, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
#             field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values) and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           (field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
#              field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values)) or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
#             field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values) and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           (field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.min(values) and
#              field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.max(values)) or ^dynamics
#         )
#       end
#     end
#   end

#   def not_between_dynamic(key, values, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           (field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
#              field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values)) and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
#             field(c, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values) or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           (field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
#              field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values)) and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) < ^Enum.min(values) or
#             field(q, ^FatHelper.string_to_existing_atom(key)) > ^Enum.max(values) or ^dynamics
#         )
#       end
#     end
#   end

#   def not_between_equal_dynamic(key, values, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           (field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
#              field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values)) and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
#             field(c, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values) or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           (field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
#              field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values)) and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) <= ^Enum.min(values) or
#             field(q, ^FatHelper.string_to_existing_atom(key)) >= ^Enum.max(values) or ^dynamics
#         )
#       end
#     end
#   end

#   def in_dynamic(key, values, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) in ^values and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) in ^values or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) in ^values and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) in ^values or ^dynamics
#         )
#       end
#     end
#   end

#   def not_in_dynamic(key, values, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) not in ^values and ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           field(c, ^FatHelper.string_to_existing_atom(key)) not in ^values or ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) not in ^values and ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           field(q, ^FatHelper.string_to_existing_atom(key)) not in ^values or ^dynamics
#         )
#       end
#     end
#   end

#   def contains_dynamic(key, values, dynamics, opts \\ []) do
#     # value = Enum.join(value, " ")
#     # where: fragment("? @> ?::jsonb", c.exclusions, ^[dish_id])

#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and
#             ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           fragment("? @> ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or
#             ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and
#             ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           fragment("? @> ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or
#             ^dynamics
#         )
#       end
#     end
#   end

#   def contains_any_dynamic(key, values, dynamics, opts \\ []) do
#     if opts[:binding] == :last do
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [..., c],
#           fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) and
#             ^dynamics
#         )
#       else
#         dynamic(
#           [..., c],
#           fragment("? && ?", field(c, ^FatHelper.string_to_existing_atom(key)), ^values) or
#             ^dynamics
#         )
#       end
#     else
#       if opts[:dynamic_type] == :and do
#         dynamic(
#           [q],
#           fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) and
#             ^dynamics
#         )
#       else
#         dynamic(
#           [q],
#           fragment("? && ?", field(q, ^FatHelper.string_to_existing_atom(key)), ^values) or
#             ^dynamics
#         )
#       end
#     end
#   end
# end
