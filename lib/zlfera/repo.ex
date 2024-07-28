defmodule Zlfera.Repo do
  use Ecto.Repo,
    otp_app: :zlfera,
    adapter: Ecto.Adapters.Postgres
end
