defmodule EmbedChat.Router do
  use EmbedChat.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug EmbedChat.Locale, "en"
    plug EmbedChat.Auth, repo: EmbedChat.Repo
    plug EmbedChat.AuthAddress, repo: EmbedChat.Repo
    plug EmbedChat.SDK, repo: EmbedChat.Repo
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug EmbedChat.AuthAPI, repo: EmbedChat.Repo
  end

  scope "/", EmbedChat do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/price", PageController, :price

    resources "/users", UserController, only: [:index, :new, :create, :show, :edit, :update]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/rooms", RoomController
    resources "/attempts", AttemptController
    resources "/auto_message_configs", AutoMessageConfigController
    resources "/messages", MessageController
  end

  scope "/manage", EmbedChat do
    pipe_through [:browser, :authenticate_user]

    # resources "/chats", VideoController
  end

  # Other scopes may use custom stacks.
  scope "/api", EmbedChat do
    pipe_through :api

    resources "/visitors", VisitorController, except: [:new, :edit]
  end
end
