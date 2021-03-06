defmodule FlashElmWeb.Router do
  use FlashElmWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", FlashElmWeb do
    # Use the default browser stack
    pipe_through(:browser)

    get("/*path", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", FlashElmWeb do
  #   pipe_through :api
  # end
end
