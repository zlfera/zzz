defmodule Zlfera.TaskGrain do
  alias Zlfera.Grains.Grain, as: G
  alias Zlfera.Repo

  def a(dqqq, yy) do
    u = "http://1.202.34.227:9998/web/bidPriceSpecialWatch?specialNo=#{dqqq}&specialName=z"

    uu = "http://1.202.34.227:9998/trade/biddingAbout/tradeRequestListWatch"
    uuu = "http://1.202.34.227:9998/trade/biddingAbout/tradeRequestListTotalWatch"
    headers = [referer: u]
    options = [params: [specialNo: dqqq]]
    {o, url} = HTTPoison.post(uuu, "", headers, options)

    page_no =
      if o == :ok do
        ceil(Jason.decode!(url.body)["total"] / 10)
      else
        a(dqqq, yy)
      end

    Enum.each(1..page_no, fn i ->
      options = [params: [specialNo: dqqq, pageNo: i, pageSize: 10]]
      {o, url} = HTTPoison.post(uu, "", headers, options)

      dd =
        if o == :ok do
          url.body |> Jason.decode!()
        else
          a(dqqq, yy)
        end

      grain(dd, yy)
    end)
  end

  def grain(dd, yy) do
    trantype =
      if yy == "S" do
        "拍卖"
      else
        "采购"
      end

    Enum.each(dd["row"], fn d ->
      if d["statusName"] != "等待交易" do
        latest_price =
          if d["statusName"] == "流拍" do
            "0"
          else
            to_string(d["matchPrice"])
          end

        attr = %{
          market_name: "guojia",
          mark_number: d["REQUESTALIAS"],
          year: d["prodDate"],
          variety: d["VARIETYNAME"],
          grade: d["GRADENAME"],
          trade_amount: to_string(d["NUM"]),
          starting_price: to_string(d["PRICE"]),
          latest_price: latest_price,
          address: d["BUYDEPOTNAME"],
          status: d["statusName"],
          trantype: trantype
        }

        changeset = G.changeset(%G{}, attr)
        Repo.insert(changeset)
      end
    end)
  end
end
