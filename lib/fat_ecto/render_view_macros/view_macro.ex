defmodule FatEcto.View do
  @moduledoc false
  defmacro __using__(options \\ []) do
    quote location: :keep do
      @opt_app unquote(options)[:otp_app]
      @app_level_configs (@opt_app && Application.get_env(@opt_app, FatEcto.View)) || []
      @unquoted_options unquote(options)
      @options Keyword.merge(@app_level_configs, @unquoted_options)

      @gettext_module @options[:gettext_module]
      @wrapper @options[:wrapper]
      @data_sanitizer @options[:data_sanitizer]

      if !@gettext_module do
        raise "please define gettext_module when using view macro"
      end

      if !@data_sanitizer do
        raise "please define data_sanitizer when using view macro"
      end

      def render("show.json", %{data: record}) do
        if @wrapper in [nil, ""] do
          @data_sanitizer.sanitize(record)
        else
          %{@wrapper => @data_sanitizer.sanitize(record)}
        end
      end

      def render("index.json", %{data: records}) do
        if @wrapper in [nil, ""] do
          @data_sanitizer.sanitize(records)
        else
          %{@wrapper => @data_sanitizer.sanitize(records)}
        end
      end

      def render("index.json", %{records: records, meta: meta, options: options}) do
        records_wrapper =
          if options[:data_to_view_as] in [nil, ""] do
            :records
          else
            options[:data_to_view_as]
          end

        meta_wrapper =
          if options[:meta_to_put_as] in [nil, ""] do
            :meta
          else
            options[:meta_to_put_as]
          end

        %{records_wrapper => @data_sanitizer.sanitize(records), meta_wrapper => meta}
      end

      def render("index.json", %{records: records, options: options}) do
        if options[:data_to_view_as] in [nil, ""] do
          @data_sanitizer.sanitize(records)
        else
          %{options[:data_to_view_as] => @data_sanitizer.sanitize(records)}
        end
      end

      def render("errors.json", %{code: code, message: message, changeset: changeset}) do
        %{error: %{code: code, message: message, errors: _translate_errors(changeset)}}
      end

      defp _translate_errors(changeset) do
        Ecto.Changeset.traverse_errors(changeset, &translate_view_error/1)
      end

      @doc """
      Translates an error message using gettext.
      """
      def translate_view_error({msg, opts}) do
        # Because error messages were defined within Ecto, we must
        # call the Gettext module passing our Gettext backend. We
        # also use the "errors" domain as translations are placed
        # in the errors.po file.
        # Ecto will pass the :count keyword if the error message is
        # meant to be pluralized.
        # On your own code and templates, depending on whether you
        # need the message to be pluralized or not, this could be
        # written simply as:
        #
        #     dngettext "errors", "1 file", "%{count} files", count
        #     dgettext "errors", "is invalid"
        #
        if count = opts[:count] do
          Gettext.dngettext(@gettext_module, "errors", msg, msg, count, opts)
        else
          Gettext.dgettext(@gettext_module, "errors", msg, opts)
        end
      end

      defoverridable translate_view_error: 1, render: 2
    end
  end
end
