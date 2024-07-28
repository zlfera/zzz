defmodule Plugs.OnePlug do
  import Plug.Conn
  def init(opts), do: opts

  def call(conn, _opts) do
    conn
    |> put_resp_header(
      "strict-transport-security",
      "max-age=31536000; includeSubDomains; preload"
    )
  end
end
