defmodule FatUtils.Table do
  @moduledoc """
  Provides utility functions for working with database tables.

  This module includes functions to generate SQL queries for common table operations,
  such as resetting the ID sequence of a table.
  """

  @doc """
  Generates a SQL query to reset the ID sequence of a given table.

  ## Parameters
    - `table`: The name of the table as a string or atom.
    - `id`: The name of the ID column as a string or atom. Defaults to `"id"`.

  ## Examples
      iex> FatUtils.Table.reset_id_seq_query("users")
      "SELECT setval('users_id_seq', (SELECT MAX(id) from \"users\"));"

      iex> FatUtils.Table.reset_id_seq_query("posts", "post_id")
      "SELECT setval('posts_post_id_seq', (SELECT MAX(post_id) from \"posts\"));"

  ## Notes
  - Ensure that the table has no records or that the sequence reset is appropriate for your use case.
  - This function only generates the SQL query. You need to execute it using your database driver or migration tool.
  """
  @spec reset_id_seq_query(table :: String.t() | atom(), id :: String.t() | atom()) :: String.t()
  def reset_id_seq_query(table, id \\ "id") do
    table_name = to_string(table)
    id_column = to_string(id)
    "SELECT setval('#{table_name}_#{id_column}_seq', (SELECT MAX(#{id_column}) from \"#{table_name}\"));"
  end
end
