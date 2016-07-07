defmodule EmbedChat.Gettext do
  @moduledoc """
  A module providing Internationalization with a gettext-based API.

  By using [Gettext](http://hexdocs.pm/gettext),
  your module gains a set of macros for translations, for example:

      import EmbedChat.Gettext

      # Simple translation
      gettext "Here is the string to translate"

      # Plural translation
      ngettext "Here is the string to translate",
               "Here are the strings to translate",
               3

      # Domain-based translation
      dgettext "errors", "Here is the error message to translate"

  See the [Gettext Docs](http://hexdocs.pm/gettext) for detailed usage.
  """
  use Gettext, otp_app: :embed_chat

  def supported_locales do
    known = Gettext.known_locales(EmbedChat.Gettext)
    allowed = config[:locales]

    Set.to_list(Set.intersection(Enum.into(known, HashSet.new), Enum.into(allowed, HashSet.new)))
  end

  defp config, do: Application.get_env(:embed_chat, __MODULE__)
end
