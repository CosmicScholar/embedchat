defmodule EmbedChat.Controllers do
  def user_rooms(conn) do
    conn.assigns.current_user |> Ecto.assoc(:rooms)
  end
end
