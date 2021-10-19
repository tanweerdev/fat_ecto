defmodule FatEcto.IncludeHelper do
  def include?(name, options, config \\ []) do
    only_key = Keyword.get(config, :only_field_name) || :only
    except_key = Keyword.get(config, :except_field_name) || :except

    cond do
      options == nil ->
        true

      name in (Keyword.get(options, only_key) || []) ->
        true

      name in (Keyword.get(options, except_key) || []) ->
        false

      Keyword.get(options, only_key) != nil ->
        false

      true ->
        true
    end
  end

  def overridables(names, options, config \\ []) do
    Enum.reduce(names, [], fn {name, parity}, acc ->
      if include?(name, options) do
        acc ++ [{name, parity}]
      else
        acc
      end
    end)
  end
end
