defmodule ZlferaWeb.UserController do
  use ZlferaWeb, :controller

  alias Zlfera.Accounts
  alias Zlfera.Accounts

  def index(conn, _params) do
    users = Accounts.list_users()
    {:ok, pid} = Agent.start_link(fn -> 0 end)
    render(conn, "index.html", users: users, pid: pid)
  end
end
