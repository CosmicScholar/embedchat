defmodule EmbedChat.RoomController do
  use EmbedChat.Web, :controller

  alias EmbedChat.Room

  plug :scrub_params, "room" when action in [:create, :update]
  plug :authenticate_user, "room" when action in [:index, :new, :create, :edit, :update, :delete]

  def index(conn, _params) do
    rooms = Repo.all(user_rooms(conn))
    render(conn, "index.html", rooms: rooms)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns.current_user
    |> build_assoc(:rooms)
    |> Room.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"room" => room_params}) do
    changeset =
      conn.assigns.current_user
    |> build_assoc(:rooms)
    |> Room.changeset(room_params)

    case Repo.insert(changeset) do
      {:ok, _room} ->
        conn
        |> put_flash(:info, "Room created successfully.")
        |> redirect(to: room_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    room = Repo.get!(user_rooms(conn), id)
    render(conn, "show.html", room: room)
  end

  def edit(conn, %{"id" => id}) do
    room = Repo.get!(user_rooms(conn), id)
    changeset = Room.changeset(room)
    render(conn, "edit.html", room: room, changeset: changeset)
  end

  def update(conn, %{"id" => id, "room" => room_params}) do
    room = Repo.get!(user_rooms(conn), id)
    changeset = Room.changeset(room, room_params)

    case Repo.update(changeset) do
      {:ok, room} ->
        conn
        |> put_flash(:info, "Room updated successfully.")
        |> redirect(to: room_path(conn, :show, room))
      {:error, changeset} ->
        render(conn, "edit.html", room: room, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    room = Repo.get!(user_rooms(conn), id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(room)

    conn
    |> put_flash(:info, "Room deleted successfully.")
    |> redirect(to: room_path(conn, :index))
  end

  defp user_rooms(conn) do
    conn.assigns.current_user |> assoc(:rooms)
  end
end