defmodule EmbedChat.Address do
  use EmbedChat.Web, :model

  schema "addresses" do
    field :uuid, Ecto.UUID
    belongs_to :user, EmbedChat.User
    belongs_to :room, EmbedChat.Room
    has_many :outgoing_messages, EmbedChat.Message, foreign_key: :from_id
    has_many :incoming_messages, EmbedChat.Message, foreign_key: :to_id
    has_many :user_logs, EmbedChat.UserLog

    timestamps
  end

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:uuid, :room_id])
    |> validate_required([:uuid, :room_id])
    |> foreign_key_constraint(:room_id)
  end

  def latest_for_user_room(query, user_id, room_id) do
    from a in query,
      where: a.user_id == ^user_id and a.room_id == ^room_id,
      order_by: [desc: a.id],
      limit: 1
  end

  def latest_for_room(query, room_id, limit) do
    from a in query,
      where: ^room_id == a.room_id,
      order_by: [desc: a.id],
      limit: ^limit
  end

  def latest_for_room(query, room_id) do
    latest_for_room(query, room_id, 1)
  end

  def latest_for_room_with_logs(query, room_id, limit) do
    query
    |> latest_for_room(room_id, limit)
    |> Ecto.Query.preload(:user_logs)
  end
end
