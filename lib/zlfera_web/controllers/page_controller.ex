defmodule ZlferaWeb.PageController do
  use ZlferaWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home)
  end

  def index(conn, _params) do
    e =
      if File.exists?("./priv/static/index.html") do
        File.read!("./priv/static/index.html") |> String.length()
      else
        ""
      end

    etag = ~s[W/"#{e |> :erlang.phash2() |> Integer.to_string(16)}"]

    conn =
      conn
      |> put_resp_header("etag", etag)
      |> put_resp_header("cache-control", "public")

    # |> put_status(:moved_permanently)

    if etag in get_req_header(conn, "if-none-match") do
      conn |> send_resp(304, "")
    else
      conn |> render(:index, layout: false)
    end
  end
end
