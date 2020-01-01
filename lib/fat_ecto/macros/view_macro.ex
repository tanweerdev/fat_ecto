defmodule FatEcto.View do
  defmacro __using__(_options) do
    quote do
      def render("show.json", %{data: record}) do
        %{data: FatEcto.RecordUtils.sanitize_map(record)}
      end
    end
  end
end
