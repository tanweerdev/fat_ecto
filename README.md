# FatEcto: Supercharge Your Ecto Queries with Ease! 🚀

[![Build Status](https://github.com/tanweerdev/fat_ecto/actions/workflows/fat_ecto.yml/badge.svg)](https://github.com/tanweerdev/fat_ecto/actions)
[![Coverage Status](https://coveralls.io/repos/github/tanweerdev/fat_ecto/badge.svg)](https://coveralls.io/github/tanweerdev/fat_ecto)
[![hex.pm version](https://img.shields.io/hexpm/v/fat_ecto.svg)](https://hex.pm/packages/fat_ecto)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/fat_ecto.svg)](https://hex.pm/packages/fat_ecto)
[![hex.pm license](https://img.shields.io/hexpm/l/fat_ecto.svg)](https://github.com/tanweerdev/fat_ecto/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/tanweerdev/fat_ecto.svg)](https://github.com/tanweerdev/fat_ecto/commits/master)

---

## Description

FatEcto is an Elixir package designed to make your life easier when working with Ecto. It simplifies query building, filtering, sorting, and pagination—so you can focus on what truly matters: building amazing applications. With FatEcto, writing complex repeating queries becomes effortless, flexible, and powerful! 💪

---

## Installation

Add `fat_ecto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    # Check https://hexdocs.pm/fat_ecto for the latest version
    {:fat_ecto, "~> 1.2"}
  ]
end
```

Then, run `mix deps.get` to install the package.

---

## Features & Modules

### ✅ FatEcto.Params.Validator – Validate Before You Query

NEW! Validate your query parameters before building queries. Catch errors early and provide clear feedback to API consumers.

```elixir
params = %{"limit" => 10, "skip" => 0}
case FatEcto.Params.Validator.validate_pagination(params, max_limit: 100) do
  {:ok, validated} -> # proceed with query
  {:error, reason} -> # handle validation error
end
```

### 🛠 FatEcto.Query.Dynamics.Buildable – Dynamic Filtering Made Easy

Tired of writing repetitive query filters? The `Buildable` module lets you dynamically filter records using flexible conditions passed from your web or mobile clients—with little to no effort! And the best part? You stay in control. 🚀

> 📚 **For comprehensive documentation with 20+ examples including complex nested queries, custom overrides, and real-world use cases, see the [FatEcto.Query.Dynamics.Buildable module documentation](https://hexdocs.pm/fat_ecto/FatEcto.Query.Dynamics.Buildable.html).**

#### Usage

```elixir
defmodule FatEcto.HospitalDynamicsBuilder do
  use FatEcto.Query.Dynamics.Buildable,
    filterable: [
      id: ["$EQUAL", "$NOT_EQUAL"]
    ],
    overrideable: ["name", "phone"],
    ignoreable: [
      name: ["%%", "", [], nil],
      phone: ["%%", "", [], nil]
    ]

  import Ecto.Query

  @impl true
  # You can implement override_buildable for your custom filters
  def override_buildable("name", "$ILIKE", value) do
    dynamic([r], ilike(fragment("(?)::TEXT", r.name), ^value))
  end

  def override_buildable(_field, _operator, _value), do: nil
end
```

---

#### Example Usage

Here are some practical examples of how to use `FatEcto.HospitalDynamicsBuilder` to dynamically build queries:

##### Example 1: Basic Filtering by ID

```elixir
# Filter hospitals with ID equal to 1
params = %{"id" => %{"$EQUAL" => 1}}
dynamics = FatEcto.HospitalDynamicsBuilder.build(params)

# Use the dynamics in a query
import Ecto.Query
query = where(FatEcto.FatHospital, ^dynamics)

# Resulting query:
# from(h in FatEcto.FatHospital, where: h.id == 1)
```

##### Example 2: Case-Insensitive Name Search

```elixir
# Filter hospitals with names containing "St. Mary"
params = %{"name" => %{"$ILIKE" => "%St. Mary%"}}
dynamics = FatEcto.HospitalDynamicsBuilder.build(params)

# Use the dynamics in a query
import Ecto.Query
query = where(FatEcto.FatHospital, ^dynamics)

# Resulting query:
# from(h in FatEcto.FatHospital, where: ilike(fragment("(?)::TEXT", h.name), ^"%St. Mary%"))
```

##### Example 3: Combining Multiple Filters

```elixir
# Filter hospitals with ID not equal to 2 AND name containing "General"
params = %{
  "id" => %{"$NOT_EQUAL" => 2},
  "name" => %{"$ILIKE" => "%General%"}
}
dynamics = FatEcto.HospitalDynamicsBuilder.build(params)

# Use the dynamics in a query
import Ecto.Query
query = where(FatEcto.FatHospital, ^dynamics)

# Resulting query:
# from(h in FatEcto.FatHospital, where: h.id != 2 and ilike(fragment("(?)::TEXT", h.name), ^"%General%"))
```

##### Example 4: Ignoring Empty or Invalid Values

```elixir
# Filter hospitals with a name, but ignore empty or invalid values
params = %{"name" => %{"$ILIKE" => "%%"}}  # Empty value is ignored
dynamics = FatEcto.HospitalDynamicsBuilder.build(params)

# Use the dynamics in a query
import Ecto.Query
query = where(FatEcto.FatHospital, ^dynamics)

# Resulting query:
# from(h in FatEcto.FatHospital)  # No filtering applied for name
```

##### Example 5: Even Complex Nested conditions

```elixir
# Filter hospitals with a name, but ignore empty or invalid values
params = %{
  "$OR" => [
    %{
      "name" => %{"$ILIKE" => "%John%"},
      "$OR" => %{"rating" => %{"$GT" => 18}, "location" => "New York"}
    },
    %{
      "start_date" => "2023-01-01",
      "$AND" => [
        %{"rating" => %{"$GT" => 4}},
        %{"email" => "fat_ecto@example.com"}
      ]
    }
  ]
}

dynamics = DoctorFilter.build(params)

# Resulting dynamic:
dynamic(
  [q],
  ((q.location == ^"New York" or q.rating > ^18) and ilike(fragment("(?)::TEXT", q.name), ^"%John%")) or
    (q.rating > ^4 and q.email == ^"fat_ecto@example.com" and q.start_date == ^"2023-01-01")
)

# You can now apply the result on where just like above examples
```

---

### 🔄 FatEcto.Sort.Sortable – Effortless Sorting

Sorting should be simple—and with `Sortable`, it is! Your frontend can send sorting parameters, and FatEcto will seamlessly generate the right sorting queries, allowing you to build powerful, customizable sorting logic without breaking a sweat. 😎

#### Usage of FatSortable

```elixir
defmodule Fat.SortQuery do
  import Ecto.Query
  use FatEcto.Sort.Sortable,
    sortable: [id: "$ASC", email: "*", name: ["$ASC", "$DESC"]],
    overrideable: ["custom_field"]

  @impl true
  def override_sortable("custom_field", "$DESC") do
    {:desc, dynamic([u], fragment("?->>'custom_field'", u.metadata))}
  end

  def override_sortable(_field, _operator), do: nil
end
```

---

### 📌 Pagination – Choose Your Strategy

FatEcto provides **two professional-grade pagination strategies**, each optimized for different use cases.

#### 🔢 FatEcto.Pagination.OffsetPaginator

**Best for:** Traditional pagination with page numbers (e.g., "Page 3 of 10")

```elixir
defmodule MyApp.Paginator do
  use FatEcto.Pagination.OffsetPaginator,
    repo: MyApp.Repo,
    default_limit: 20,
    max_limit: 100
end

# Offset/Limit style
query = from(u in User, where: u.active == true)
{:ok, result} = MyApp.Paginator.paginate(query, offset: 20, limit: 10)

# Page/PageSize style (more user-friendly)
{:ok, result} = MyApp.Paginator.paginate(query, page: 3, page_size: 10)

# Rich metadata
result.metadata
# => %{
#   total_count: 156,
#   total_pages: 16,
#   current_page: 3,
#   has_next_page: true,
#   has_previous_page: true,
#   is_first_page: false,
#   is_last_page: false,
#   ...
# }
```

**Features:**
- ✅ Dual API (offset/limit and page/page_size)
- ✅ Total count and page numbers
- ✅ Jump to any page
- ✅ Built-in validation
- ✅ Efficient count queries

#### 🔗 FatEcto.Pagination.CursorPaginator

**Best for:** Large datasets, real-time feeds, infinite scroll

**Relay-compliant** cursor-based pagination following GraphQL Cursor Connections Specification.

```elixir
defmodule MyApp.CursorPaginator do
  use FatEcto.Pagination.CursorPaginator,
    repo: MyApp.Repo,
    default_limit: 20,
    max_limit: 100
end

# Forward pagination (next page)
query = from(u in User, order_by: [asc: u.inserted_at, asc: u.id])
{:ok, result} = MyApp.CursorPaginator.paginate(query,
  cursor_fields: [:inserted_at, :id],
  first: 10
)

# Next page using cursor
{:ok, next_page} = MyApp.CursorPaginator.paginate(query,
  cursor_fields: [:inserted_at, :id],
  first: 10,
  after: result.page_info.end_cursor
)

# Relay-compliant structure
result
# => %{
#   edges: [
#     %{cursor: "g3QAAAACZAAKaW5zZXJ0ZWRfYXR...", node: %User{}},
#     ...
#   ],
#   page_info: %{
#     has_next_page: true,
#     has_previous_page: false,
#     start_cursor: "...",
#     end_cursor: "..."
#   }
# }
```

**Features:**
- ✅ Stable results (unaffected by concurrent changes)
- ✅ Efficient for large datasets (no OFFSET penalty)
- ✅ Bidirectional (forward & backward)
- ✅ Relay/GraphQL compatible
- ✅ Opaque, secure cursors (Base64-encoded)

#### 📊 Which Pagination to Use?

| Criterion | OffsetPaginator | CursorPaginator |
|-----------|-----------------|-----------------|
| **Page numbers** | ✅ Yes | ❌ No |
| **Jump to page** | ✅ Yes | ❌ No |
| **Total count** | ✅ Yes | ⚠️ Optional (expensive) |
| **Large datasets** | ⚠️ Slow with high offsets | ✅ Fast |
| **Real-time feeds** | ❌ Inconsistent | ✅ Stable |
| **GraphQL/Relay** | ❌ Not compatible | ✅ Native support |
| **Simple UI** | ✅ Perfect | ⚠️ Infinite scroll only |
| **Dataset changes** | ⚠️ May show duplicates | ✅ Consistent |

---

## 🎯 Best Practices

### Parameter Validation

Always validate user-provided parameters before building queries to prevent errors and provide clear feedback:

```elixir
# Define your validation rules
filterable_fields = %{
  "name" => ["$ILIKE"],
  "age" => ["$GT", "$GTE", "$LT", "$LTE"],
  "email" => ["$EQUAL"]
}

sortable_fields = %{
  "name" => ["$ASC", "$DESC"],
  "created_at" => "*"  # Allow all sort directions
}

# Validate all parameters at once
params = %{
  "filter" => %{"name" => %{"$ILIKE" => "%John%"}, "age" => %{"$GT" => 18}},
  "sort" => %{"created_at" => "$DESC"},
  "limit" => 20,
  "skip" => 0
}

case FatEcto.Params.Validator.validate(params,
  filterable_fields: filterable_fields,
  sortable_fields: sortable_fields,
  max_limit: 100
) do
  {:ok, validated_params} ->
    # Build and execute your query
    dynamics = MyApp.UserFilter.build(params["filter"])
    order_by = MyApp.UserSort.build(params["sort"])

    query = from(u in User, where: ^dynamics, order_by: ^order_by)
    MyApp.Paginator.paginate(query, limit: params["limit"], skip: params["skip"])

  {:error, errors} ->
    # Return validation errors to the user
    {:error, errors}
end
```

### Combining All Features

Here's a complete example combining filtering, sorting, and pagination:

```elixir
defmodule MyApp.UserQueryBuilder do
  import Ecto.Query

  def search_users(params) do
    # 1. Validate parameters
    with {:ok, _} <- validate_params(params),
         # 2. Build dynamics for filtering
         dynamics <- MyApp.UserFilter.build(params["filter"]),
         # 3. Build order_by for sorting
         order_by <- MyApp.UserSort.build(params["sort"]),
         # 4. Build base query
         query <- apply_filters_and_sorting(dynamics, order_by),
         # 5. Paginate
         {:ok, result} <- MyApp.Paginator.paginate(query,
           limit: params["limit"],
           skip: params["skip"]) do
      {:ok, result}
    end
  end

  defp validate_params(params) do
    FatEcto.Params.Validator.validate(params,
      filterable_fields: %{"name" => ["$ILIKE"], "age" => ["$GT", "$LT"]},
      sortable_fields: %{"name" => ["$ASC", "$DESC"]},
      max_limit: 100
    )
  end

  defp apply_filters_and_sorting(dynamics, order_by) do
    from(u in User)
    |> where(^dynamics)
    |> order_by(^order_by)
  end
end
```

---

## 🚀 Contributing

We love contributions! If you’d like to improve FatEcto, submit an issue or pull request. Let’s build something amazing together! 🔥

---

## 📜 License

FatEcto is released under the MIT License.

📖 See the full documentation at [HexDocs](https://hexdocs.pm/fat_ecto/) for more details.
