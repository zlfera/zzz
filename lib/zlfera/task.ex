defmodule Zlfera.Task do
  alias Zlfera.TaskGrain, as: Zg
  alias Zlfera.Accounts.User, as: G
  import Ecto.Query

  def run() do
    {:ok, _} = Application.ensure_all_started(:zlfera)

    u1(b())
  end

  def year() do
    url = "www.ex-grain.cn/jrjj.htm"
    body = HTTPoison.get!(url).body
    urls = Floki.find(body, "table tr td a.new_jrjy") |> Floki.attribute("href")

    if !Enum.empty?(urls) do
      l =
        for url <- urls do
          url = "http://www.ex-grain.cn/#{url}"
          body = HTTPoison.get!(url, recv_timeout: 1000).body
          tr = Floki.find(body, "table.MsoNormalTable tbody tr")

          l =
            for t <- tr do
              g = Floki.find(t, "tr")
              Floki.text(g)
            end

          l = List.delete_at(l, 0)
          l = List.delete_at(l, 0)
          List.delete_at(l, 0)

          # for w <- l do
          # String.split(w, ",", trim: true)
          # end
        end

      l =
        Enum.reject(l, fn x -> length(x) == 0 end)
        |> Enum.map_join(",", fn x -> Enum.join(x, ",") end)
        |> String.split(",")

      z =
        Zlfera.Grains.Grain
        |> Ecto.Query.limit(100)
        |> Ecto.Query.order_by(desc: :inserted_at)
        |> Zlfera.Repo.all()

      {:ok, pid} = Agent.start_link(fn -> [] end)
      Agent.update(pid, fn _ -> l end)

      Enum.each(z, fn x ->
        Enum.each(Agent.get(pid, & &1), fn xx ->
          if String.contains?(xx, x.mark_number) do
            [xx | _] = String.split(xx, x.variety)
            [i] = ~r/\d+$/ |> Regex.run(xx)
            post = Ecto.Changeset.change(x, year: i)
            Zlfera.Repo.update(post)
            Agent.update(pid, &List.delete(&1, xx))
          end
        end)
      end)
    end
  end

  def phone do
    u = "https://trade.gdgrain.com/sgtcTrade-front/sgtc/activity/SAct013"

    body =
      "{\"channelCode\": \"04\",\"pageNo\": \"1\",\"pageSize\": \"10\",\"statusType\": \"WI\"}"

    options = [params: [channelCode: "04"]]
    headers = ["content-type": "application/json;charset=UTF-8"]
    {:ok, url} = HTTPoison.post(u, body, headers, options)
    code = url.body |> Jason.decode!()
    total = code["result"]["total"]
    page_no = ceil(total / 10)

    tasks =
      for p <- 1..page_no do
        Process.sleep(60000)

        Task.async(fn ->
          options = [params: [channelCode: "04"], recv_timeout: 15000]

          body =
            "{\"channelCode\": \"04\",\"pageNo\": \"#{p}\",\"pageSize\": \"10\",\"statusType\": \"WI\"}"

          {:ok, url} = HTTPoison.post(u, body, headers, options)
          code = url.body |> Jason.decode!()

          code = code["result"]["activityList"]

          code =
            for x <- code do
              uuu = "https://trade.gdgrain.com/sgtcTrade-front/sgtc/activity/SAct009"

              options = [
                params: [activityNum: x["activityNum"], channelCode: "04"],
                recv_timeout: 15000
              ]

              body = "{\"channelCode\": \"04\",\"activityNum\": \"#{x["activityNum"]}\"}"
              {:ok, url} = HTTPoison.post(uuu, body, headers, options)
              code = url.body |> Jason.decode!()
              code["result"]["cusId"]
            end

          for code <- code do
            uuuu = "https://trade.gdgrain.com/sgtcTrade-front/sgtc/commonality/SCus001"

            options = [params: [channelCode: "04", custId: code], recv_timeout: 15000]
            body = "{\"channelCode\": \"04\",\"custId\": \"#{code}\"}"
            {:ok, url} = HTTPoison.post(uuuu, body, headers, options)
            code = url.body |> Jason.decode!()
            code["result"]
          end
        end)
      end

    tasks = Task.yield_many(tasks, 30000)

    results =
      Enum.map(tasks, fn {_, res} ->
        res
      end)

    values =
      for {:ok, value} <- results do
        value
      end

    values = List.flatten(values)

    Enum.each(values, fn x ->
      attr = %{
        address: x["address"],
        arti_person: x["artiPerson"],
        arti_phone: x["artiPhone"],
        bank_id: x["bankId"],
        busi_name: x["busiName"],
        busi_type: x["busiType"],
        cert_code: x["certCode"],
        cust_id: x["custId"],
        deposit_bank: x["depositBank"],
        email: x["email"],
        fax: x["fax"],
        link_mane: x["linkMane"],
        link_phone: x["linkPhone"],
        manage_type: x["manageType"],
        phone: x["phone"]
      }

      changeset = G.changeset(%G{}, attr)

      Zlfera.Repo.insert(changeset)
    end)
  end

  # 1
  # u="https://trade.gdgrain.com/sgtcTrade-front/sgtc/activity/SAct006"
  # body="{\"channelCode\": \"04\",\"currentDate\": \"2019-07-15\"}"
  # headers = ["content-type": "application/json;charset=UTF-8"]
  # 参数固定为04
  # options=[params: [channelCode: "04",currentDate: "2019-07-15"]]
  # {o, url} = HTTPoison.post(u, body, headers, options)
  # 2
  # uu = "https://trade.gdgrain.com/sgtcTrade-front/sgtc/targets/STar001"
  # headers = ["content-type": "application/json;charset=UTF-8"]
  # body="{\"channelCode\": \"04\",\"activityNum\": \"8C1CAECE87EF4EAF8986D11BA21E980F\"}"
  # options=[params: ["activityNum": "0635D66BAC634FD382476F54C9959AC6","channelCode": "04"]]
  # {o, url} = HTTPoison.post(uu, body, headers, options)
  # 3
  # uuu = "https://trade.gdgrain.com/sgtcTrade-front/sgtc/activity/SAct009"
  # headers = ["content-type": "application/json;charset=UTF-8"]
  # options=[params: ["activityNum": "0635D66BAC634FD382476F54C9959AC6","channelCode": "04"]]
  # body="{\"channelCode\": \"04\",\"activityNum\": \"8C1CAECE87EF4EAF8986D11BA21E980F\"}"
  # {o, url} = HTTPoison.post(uuu, body, headers, options)
  # 4
  # uuuu="https://trade.gdgrain.com/sgtcTrade-front/sgtc/commonality/SCus001"
  # headers = ["content-type": "application/json;charset=UTF-8"]
  # options=[params: [channelCode: "04",custId: "4402118018"]]
  # body="{\"channelCode\": \"04\",\"custId\": \"4401117026\"}"
  # {o, url} = HTTPoison.post(uuuu, body, headers, options)
  def b do
    # u = "http://59.55.120.113:8311/web/bidPriceSpecialWatch?specialNo=1018&specialName=num"
    # uu = "http://59.55.120.113:8311/trade/open/watchSpecial"
    u = "http://59.55.120.113:8311/trade/open/findSpecialMessageByCondition"
    # u = "http://59.55.120.113:8311/trade/biddingAbout/tradeRequestListWatch"
    # uuuu = "http://59.55.120.113:8311/web/bidPrice"
    # headers = [referer: u]
    options = [params: [ckType: "plan", specialType: "7801"]]
    {o, url} = HTTPoison.post(u, "", [], options)

    if o == :ok do
      url.body |> Jason.decode!()
    else
      b()
    end
  end

  def u1(c) do
    tasks =
      for x <- c["row"] do
        y = x["specialNo"]
        yy = x["selfBS"]
        Task.async(Zg, :a, [y, yy])
      end

    Task.yield_many(tasks, 10000)
  end
end
