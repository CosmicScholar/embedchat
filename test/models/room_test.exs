defmodule EmbedChat.RoomTest do
  use EmbedChat.ModelCase

  alias EmbedChat.Room

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Room.changeset(%Room{}, @valid_attrs)
    assert changeset.valid?
  end
end