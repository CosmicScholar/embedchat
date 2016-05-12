defmodule EmbedChat.AttemptController do
  use EmbedChat.Web, :controller
  use Hound.Helpers

  alias EmbedChat.Attempt
  alias EmbedChat.Room

  plug :authenticate_user when action in [:index, :update, :edit, :delete]
  plug :scrub_params, "attempt" when action in [:create, :update]

  def index(conn, _params) do
    attempts = Repo.all(Attempt)
    render(conn, "index.html", attempts: attempts)
  end

  def new(conn, _params) do
    changeset = Attempt.changeset(%Attempt{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"attempt" => attempt_params}) do
    changeset = Attempt.changeset(%Attempt{}, attempt_params)

    case Repo.insert(changeset) do
      {:ok, attempt} ->
        conn
        |> put_flash(:info, "Attempt created successfully.")
        |> redirect(to: attempt_path(conn, :show, attempt))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    attempt = Repo.get!(Attempt, id)
    room = Repo.get!(Room, 1)
    source = get_source(attempt.url)
    if source == "<html><head></head><body></body></html>" do
      render(conn, "show.html", data: "Not found :( <br> url: #{attempt.url}", room: room)
    else
      render(conn, "show.html", data: source, room: room)
    end
  end

  def edit(conn, %{"id" => id}) do
    attempt = Repo.get!(Attempt, id)
    changeset = Attempt.changeset(attempt)
    render(conn, "edit.html", attempt: attempt, changeset: changeset)
  end

  def update(conn, %{"id" => id, "attempt" => attempt_params}) do
    attempt = Repo.get!(Attempt, id)
    changeset = Attempt.changeset(attempt, attempt_params)

    case Repo.update(changeset) do
      {:ok, attempt} ->
        conn
        |> put_flash(:info, "Attempt updated successfully.")
        |> redirect(to: attempt_path(conn, :show, attempt))
      {:error, changeset} ->
        render(conn, "edit.html", attempt: attempt, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    attempt = Repo.get!(Attempt, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(attempt)

    conn
    |> put_flash(:info, "Attempt deleted successfully.")
    |> redirect(to: attempt_path(conn, :index))
  end

  defp get_source(url) do
    new_url = get_url(url)
    Hound.start_session
    navigate_to(new_url)
    source = page_source
    Hound.end_session
    String.replace(source, ~r/(href|src)=(\"|\')\/([a-zA-Z0-9])/, "\\1=\\\2#{get_host(url)}/\\3")
  end

  defp get_url(url) do
    new_url = URI.encode(url)
    if URI.parse(new_url).scheme do
      new_url
    else
      "http://" <> new_url
    end
  end

  defp get_host(url) do
    uri = URI.parse(get_url(url))
    uri.scheme <> "://" <> uri.host
  end
end