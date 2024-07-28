defmodule ZlferaWeb.GrainController do
  use ZlferaWeb, :controller
  alias Zlfera.Grains, as: Gg

  def index(conn, params) do
    grains =
      if Map.has_key?(params, "td_data") && params["td_data"] != "" do
        [x, y] = params["td_data"] |> String.split(",")
        Gg.grains_list(x, y)
      else
        if Map.has_key?(params, "search") do
          Gg.search_grains(params["search"])
        else
          Gg.list_grains()
        end
      end

    {:ok, pid} = Agent.start_link(fn -> 0 end)
    render(conn, "index.html", grains: grains, pid: pid)
  end
end
