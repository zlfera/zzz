defmodule ZlferaWeb.Router do
  use ZlferaWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {ZlferaWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug Plugs.OnePlug
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ZlferaWeb do
    pipe_through :browser
    get "/home", PageController, :home
    get "/", PageController, :index
    get "/grains", GrainController, :index
    post "/grains", GrainController, :index
    get "/index", HomeController, :index
    get "/fengya", FengYaController, :index
    get "/phone", UserController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", ZlferaWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:zlfera, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: ZlferaWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
