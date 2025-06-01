defmodule FatEcto.Query.Dynamics.Helper do
  @moduledoc """
  Provides helper functions for Dynamics.
  """
  import Ecto.Query

  @doc """
  Merges two dynamic expressions using the specified operator.
  If either dynamic is nil, it returns the other dynamic.
  If both are nil, it returns nil.
  The operator can be `:and` or `:or`.
  """
  @spec merge_dynamics(Ecto.Query.dynamic_expr() | nil, Ecto.Query.dynamic_expr() | nil, atom) ::
          Ecto.Query.dynamic_expr() | nil
  def merge_dynamics(dynamic1, dynamic2, operator \\ :and)

  def merge_dynamics(nil, dynamic, _operator), do: dynamic
  def merge_dynamics(dynamic, nil, _operator), do: dynamic

  def merge_dynamics(dynamic1, dynamic2, :or) do
    dynamic([q], ^dynamic1 or ^dynamic2)
  end

  def merge_dynamics(dynamic1, dynamic2, :and) do
    dynamic([q], ^dynamic1 and ^dynamic2)
  end
end
