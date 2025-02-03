# FatEcto


[![Build Status](https://github.com/tanweerdev/fat_ecto/workflows/tests/badge.svg)](https://github.com/parroty/excoveralls/actions)
[![Coverage Status](https://coveralls.io/repos/github/tanweerdev/fat_ecto/badge.svg?branch=master)](https://coveralls.io/github/tanweerdev/fat_ecto?branch=master)
[![hex.pm version](https://img.shields.io/hexpm/v/fat_ecto.svg)](https://hex.pm/packages/fat_ecto)
[![hex.pm downloads](https://img.shields.io/hexpm/dt/fat_ecto.svg)](https://hex.pm/packages/fat_ecto)
[![hex.pm license](https://img.shields.io/hexpm/l/fat_ecto.svg)](https://github.com/tanweerdev/fat_ecto/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/tanweerdev/fat_ecto.svg)](https://github.com/tanweerdev/fat_ecto/commits/master)

## Description

FatEcto is an Elixir package designed to simplify and enhance Ecto query building, pagination, sorting, and data sanitization. It provides a set of utilities and modules that make it easier to work with Ecto in your Elixir applications.

## Installation

Add `fat_ecto` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    # Check https://hexdocs.pm/fat_ecto for latest version
    {:fat_ecto, "~> 1.0.0"}
  ]
end
```

Then, run mix deps.get to install the package.

## Modules

### FatEcto.FatQuery.Whereable

The Whereable module provides functionality to filter Ecto queries using predefined filterable and overrideable fields.

#### Usage

```elixir
defmodule MyApp.HospitalFilter do
  use FatEcto.FatQuery.Whereable,
    filterable_fields: %{
      "id" => ["$eq", "$neq"]
    },
    overrideable_fields: ["name", "phone"],
    ignoreable_fields_values: %{
      "name" => ["%%", "", [], nil],
      "phone" => ["%%", "", [], nil]
    }

  import Ecto.Query

  def override_whereable(query, "name", "$ilike", value) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.name), ^value))
  end

  def override_whereable(query, "phone", "$ilike", value) do
    where(query, [r], ilike(fragment("(?)::TEXT", r.phone), ^value))
  end

  def override_whereable(query, _, _, _) do
    query
  end
end
```

### FatEcto.FatQuery.Sortable

The Sortable module allows sorting Ecto queries based on user-defined rules.

#### Usage

```elixir
defmodule MyApp.SortQuery do
  import Ecto.Query
  use FatEcto.FatQuery.Sortable,
    sortable_fields: %{"id" => "$asc", "name" => ["$asc", "$desc"]},
    overrideable_fields: ["custom_field"]

  @impl true
  def override_sortable(query, field, operator) do
    case {field, operator} do
      {"custom_field", "$asc"} ->
        from(q in query, order_by: [asc: fragment("?::jsonb->>'custom_field'", q)])
      _ ->
        query
    end
  end
end
```

### FatEcto.FatPaginator

The FatPaginator module provides pagination functionality for Ecto queries.

#### Usage

```elixir
defmodule MyApp.MyContext do
  use FatEcto.FatPaginator, repo: MyApp.Repo

  # Custom functions can be added here
end
```

### FatEcto.DataSanitizer

The DataSanitizer module provides functionality to sanitize records and convert data into views.

#### Usage

```elixir
defmodule MyApp.MyContext do
  use FatEcto.DataSanitizer

  # Custom functions can be added here
end
```

### Utilities

FatEcto also includes a set of utility functions for various purposes, such as changeset validation, datetime handling, map manipulation, and table operations. These utilities are designed to make common tasks easier and more consistent.

Example Usage

```elixir
# Example of using a utility function
alias FatEcto.Utils.MapUtils

data = %{name: "John", age: 30, email: "john@example.com"}
filtered_data = MapUtils.filter_keys(data, [:name, :email])
```

### Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

License
MIT License

Copyright (c) 2023 Muhammad Tanweer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

see [Docs](https://hexdocs.pm/fat_ecto/) for more details.
