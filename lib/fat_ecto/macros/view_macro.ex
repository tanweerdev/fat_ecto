defmodule FatEcto.View do
  @moduledoc false
  defmacro __using__(options) do
    quote do
      @gettext_module unquote(options)[:gettext_module]
      if !@gettext_module do
        raise "please define gettext_module when using view macro"
      end

      def render("show.json", %{data: record}) do
        %{data: FatEcto.RecordUtils.sanitize_map(record)}
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

      defoverridable translate_view_error: 1
    end
  end
end
