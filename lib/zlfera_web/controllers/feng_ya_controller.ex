defmodule ZlferaWeb.FengYaController do
  use ZlferaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
