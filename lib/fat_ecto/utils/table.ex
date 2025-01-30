defmodule FatUtils.Table do
  @moduledoc """
    Provides methods to work with table
  """

  # @doc """
  #   It will reset id sequence of any given table. Please make sure there are no records
  # """
  # TODO: WIP

  @spec reset_id_seq_query(any(), any()) :: <<_::64, _::_*8>>
  def reset_id_seq_query(table, id \\ "id") do
    # You can run inside execute of any migration
    "SELECT setval('#{table}_#{id}_seq', (SELECT MAX(#{id}) from \"#{table}\"));"
  end
end
