defmodule FatEcto.IQCRUD do
  defmacro __using__(opts \\ []) do
    # quote location: :keep do
    # TODO: start using bind_quoted in all macros
    quote location: :keep, bind_quoted: [opts: opts] do
      import FatEcto.IncludeHelper

      @opt_app opts[:otp_app]
      @app_level_configs (@opt_app && Application.get_env(@opt_app, FatEcto.IQCRUD)) || []
      @unquoted_options opts
      options = Keyword.merge(@app_level_configs, @unquoted_options)
      use FatEcto.RenderUtils, Keyword.merge(options, options[:render_utils] || [])

      if include?(:delete, options) do
        use FatEcto.DeleteRecord, Keyword.merge(options, options[:delete_method] || [])
      end

      if include?(:update, options) do
        use FatEcto.UpdateRecord, Keyword.merge(options, options[:update_method] || [])
      end

      if include?(:create, options) do
        use FatEcto.CreateRecord, Keyword.merge(options, options[:create_method] || [])
      end

      if include?(:index, options) do
        use FatEcto.IndexRecord, Keyword.merge(options, options[:index_method] || [])
      end

      if include?(:show, options) do
        use FatEcto.ShowRecord, Keyword.merge(options, options[:show_method] || [])
      end

      if include?(:query_by, options) do
        use FatEcto.ByQuery, Keyword.merge(options, options[:query_by_method] || [])
      end

      defoverridable create: 2, update: 2, show: 2, index: 2, delete: 2, query_by: 2
    end
  end
end
