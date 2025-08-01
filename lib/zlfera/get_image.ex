defmodule Zlfera.GetImage do
  def get_img do
    # url = "http://cn.bing.com/HPImageArchive.aspx?format=js&idx=0&n=1"
    # url = HTTPoison.get!(url).body |> Jason.decode!
    # # url = url["images"] |> List.first()
    # "http://s.cn.bing.net" <> url["url"]
    b = HTTPoison.get!("https://touduyu.com").body
    {:ok, b} = Floki.parse_document(b)
    [url] = Floki.attribute(b, "body", "style")
    url
  end

  def get_text do
    url = "http://m.wufazhuce.com/one/" |> HTTPoison.get!()
    [_, _, _, _, {_, cookie1}, _, _, _] = url.headers
    {:ok, html} = Floki.parse_document(url.body)
    body = html |> Floki.find("div .ui-content script")
    [{_, _, [token]}] = body
    [_, token] = Regex.split(~r{= '}, token)
    [token, _] = ~r{';} |> Regex.split(token)

    res =
      HTTPoison.request!(
        :post,
        "http://m.wufazhuce.com/one/ajaxlist/" <> "0" <> "?_token=" <> token,
        "",
        [{"Cookie", cookie1}]
      )

    [h | _] = Jason.decode!(~s(#{res.body}))["data"]
    # Jason.encode!(h)
    h
  end

  def n do
    [_, i] = Regex.split(~r{\(}, get_img())
    [i, _] = Regex.split(~r{\)}, i)
    image = HTTPoison.get!(i, recv_timeout: 10000).body
    File.write("./lib/zlfera-0.1.0/priv/static/images/background_image.jpeg", image)
    # html = HTTPoison.get!("www.youmile.vip/", recv_timeout: 10000).body
    # File.write("./priv/static/index.html", get_text())
  end
end
