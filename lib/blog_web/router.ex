defmodule BlogWeb.Router do
  use BlogWeb, :router

  import BlogWeb.Admin.AdminAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :instrospect
    plug :fetch_live_flash
    plug :put_root_layout, {BlogWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
  end

  pipeline :admin_upload do
    plug :accepts, ["json"]
    plug :fetch_session
    plug :instrospect
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_admin
  end

  alias Blog.Metric.StatsServer

  def instrospect(conn, _) do
    if Mix.env() != :test do
      StatsServer.record_metric(%{
        request_path: conn.request_path,
        method: conn.method,
        remote_ip: conn.remote_ip |> Tuple.to_list() |> Enum.join(".")
      })
    end

    conn
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :admin_redirect_if_authenticated do
    plug :redirect_if_admin_is_authenticated
  end

  pipeline :admin_require_authenticated do
    plug :require_authenticated_admin
  end

  scope "/", BlogWeb do
    get "/up", HealthController, :show
  end

  scope "/", BlogWeb do
    pipe_through :browser

    live_session :blog_current_admin,
      on_mount: [{BlogWeb.Admin.AdminAuth, :mount_current_admin}] do
      live "/", ArticleLive.Index, :index
      live "/articles/:slug", ArticleLive.Show, :show

      live "/about", AboutLive.Index, :index
    end

    get "/feed", FeedController, :index
  end

  scope "/admin", BlogWeb do
    pipe_through [:browser, :admin_require_authenticated]

    get "/articles", AdminArticleController, :index
    get "/articles/new", AdminArticleController, :new
    post "/articles", AdminArticleController, :create
    get "/articles/:id/edit", AdminArticleController, :edit
    put "/articles/:id", AdminArticleController, :update
  end

  scope "/admin", BlogWeb do
    pipe_through [:admin_upload, :admin_require_authenticated]

    post "/uploads/images", AdminUploadController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", BlogWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: BlogWeb.Telemetry
    end
  end

  # Enables the Swoosh mailbox preview in development.
  #
  # Note that preview only shows emails that were sent by the same
  # node running the Phoenix server.
  if Mix.env() == :dev do
    scope "/dev" do
      pipe_through :browser

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/admin", BlogWeb.Admin, as: :admin do
    pipe_through [:browser, :admin_redirect_if_authenticated]

    live_session :redirect_if_admin_is_authenticated,
      layout: {BlogWeb.LayoutView, :auth_live},
      on_mount: [{BlogWeb.Admin.AdminAuth, :redirect_if_admin_is_authenticated}] do
      live "/admins/log_in", AdminLoginLive, :new
      live "/admins/reset_password", AdminForgotPasswordLive, :new
      live "/admins/reset_password/:token", AdminResetPasswordLive, :edit
    end

    post "/admins/log_in", AdminSessionController, :create
  end

  scope "/admin", BlogWeb.Admin, as: :admin do
    pipe_through [:browser, :admin_require_authenticated]

    live_session :require_authenticated_admin,
      layout: {BlogWeb.LayoutView, :auth_live},
      on_mount: [{BlogWeb.Admin.AdminAuth, :ensure_authenticated}] do
      live "/admins/settings", AdminSettingsLive, :edit
      live "/admins/settings/confirm_email/:token", AdminSettingsLive, :confirm_email
    end
  end

  scope "/admin", BlogWeb.Admin, as: :admin do
    pipe_through [:browser]

    delete "/admins/log_out", AdminSessionController, :delete

    live_session :current_admin,
      layout: {BlogWeb.LayoutView, :auth_live},
      on_mount: [{BlogWeb.Admin.AdminAuth, :mount_current_admin}] do
      live "/admins/confirm/:token", AdminConfirmationLive, :edit
      live "/admins/confirm", AdminConfirmationInstructionsLive, :new
    end
  end
end
