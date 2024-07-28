defmodule ZlferaWeb.HomeController do
  use ZlferaWeb, :controller

  def index(conn, _params) do
    redirect(conn, external: "https://youmile.youhaovip.com")
  end
end
